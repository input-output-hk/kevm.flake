{ cmake
, cryptopp
, jemalloc
, k
, kore
, lib
, libff
, libffi
, libyamlcpp
, llvm-backend
, mpfr
, ncurses
, openjdk
, openssl
, pkgconfig
, procps
, protobuf
, python
, secp256k1
, src
, stdenv
, which
, z3
}:

let
  version = "0";
  inherit (llvm-backend.passthru) clang lld;

  mkEVM = target: f: stdenv.mkDerivation (f {
    pname = "evm-${target}";
    inherit version src;
    nativeBuildInputs = [ protobuf k llvm-backend clang cmake which openssl pkgconfig procps kore lld ];
    buildInputs = [ cryptopp libff mpfr secp256k1 ];
    patches = [ ./make.patch ];

    postPatch = ''
      patchShebangs ./kevm
    '';
    dontConfigure = true;
    makeFlags =
      [
        "INSTALL_PREFIX=${builtins.placeholder "out"}"
        "SKIP_LLVM=true"
        "SKIP_HASKELL=true"
        "SYSTEM_LIBFF=true"
        "SYSTEM_LIBSECP256K1=true"
        "SYSTEM_LIBCRYPTOPP=true"
      ];
    buildFlags = [ "build-${target}" ];
    installPhase = ''
      mkdir -p $out/bin
      cp .build/${builtins.placeholder "out"}/lib/kevm/node/build/kevm-${target} $out/bin/
    '';
  });

  kevm-vm = mkEVM "vm" (x: x);

  host-PATH = lib.makeBinPath [ k llvm-backend kore ];
in
stdenv.mkDerivation {
  pname = "kevm";
  inherit version src;
  patches = [ ./make.patch ];

  postPatch = ''
    sed -i kevm \
      -e "/^export LD_LIBRARY_PATH=/ d" \
      -e '2 i export PATH="${host-PATH}:$PATH"'

    patchShebangs ./kevm
  '';

  makeFlags = [
    "INSTALL_PREFIX=${builtins.placeholder "out"}"
    "SKIP_LLVM=true"
    "SKIP_HASKELL=true"
    "SYSTEM_LIBFF=true"
    "SYSTEM_LIBSECP256K1=true"
    "SYSTEM_LIBCRYPTOPP=true"
  ];

  # NIX_CFLAGS_COMPILE = [ "-Wno-unused-command-line-argument" ];

  preBuild = ''
    make plugin-deps "INSTALL_PREFIX=${builtins.placeholder "out"}"
  '';

  postInstall = "ln -s ${kevm-vm}/bin/kevm-vm $out/bin/";
  buildFlags = [ "build-kevm" ];

  passthru = { inherit kevm-vm; };
}
