{ lib
, src
, cmake
, flex
, pkgconfig
, llvmPackages_11
, boost
, gmp
, jemalloc
, libffi
, libiconv
, libyaml
, mpfr
, ncurses
, # Options:
  release ? true  # optimized release build, currently: LTO
}:


let
  llvmPackages = llvmPackages_11.override {
    bootBintoolsNoLibc = null;
    bootBintools = null;
  };
  inherit (llvmPackages) stdenv llvm;

  clang = llvmPackages.clangNoLibcxx.override (attrs: {
    extraBuildCommands = ''
      ${attrs.extraBuildCommands}
      sed -i $out/nix-support/cc-cflags -e '/^-nostdlib/ d'
    '';
  });

  pname = "llvm-backend";
  version = "0";
in

stdenv.mkDerivation {
  inherit pname version src;

  nativeBuildInputs = [ cmake flex llvm pkgconfig ];
  buildInputs = [ boost libyaml ];
  propagatedBuildInputs =
    [ gmp jemalloc libffi mpfr ncurses ]
    ++ lib.optional stdenv.isDarwin libiconv;

  postPatch = ''
    sed -i bin/llvm-kompile \
      -e '2a export PATH="${lib.getBin clang}/bin:''${PATH}"'
  '';

  cmakeFlags = [
    ''-DCMAKE_C_COMPILER=${lib.getBin stdenv.cc}/bin/cc''
    ''-DCMAKE_CXX_COMPILER=${lib.getBin stdenv.cc}/bin/c++''
    ''-DLLVM_CLANG_PATH=${lib.getBin clang}/bin/clang''
    ''-DLLVM_CONFIG_PATH=${lib.getBin llvmPackages.libllvm.dev}/bin/llvm-config''
    ''-DUSE_NIX=TRUE''
    ''-DCMAKE_SKIP_BUILD_RPATH=FALSE''
  ];

  cmakeBuildType = if release then "Release" else "FastBuild";

  NIX_CFLAGS_COMPILE = [ "-Wno-error" ];

  postInstall = ''
    mkdir -p $out/lib/cmake/kframework
    cp -r ../cmake/* $out/lib/cmake/kframework/;
  '';

  doCheck = false;

  passthru = {
    inherit clang;
  };
}
