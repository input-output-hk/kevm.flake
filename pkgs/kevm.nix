{ cmake
, cryptopp
, k
, kore
, lib
, libff
, llvm-backend
, mpfr
, openssl
, pkgconfig
, procps
, protobuf
, secp256k1
, patches
, stdenv
, which
, inputs
, pname
, version
}:

let
  inherit (llvm-backend.passthru) clang lld;

  host-PATH = lib.makeBinPath [ k llvm-backend kore ];
in
stdenv.mkDerivation {
  src = inputs.kevm;
  inherit pname version patches;

  nativeBuildInputs = [ protobuf k llvm-backend clang cmake which openssl pkgconfig procps kore lld ];
  buildInputs = [ cryptopp libff mpfr secp256k1 ];

  dontConfigure = true;

  prePatch = ''
    rm -rf deps/{k, plugin}

    cp -r ${inputs.k}/ -T deps/k
    cp -r ${inputs.blockchain-plugin}/ -T deps/plugin

    chmod -R a=r-wx,u=wr,a+X deps
  '';

  postPatch = ''
    sed -i kevm \
      -e "/^export LD_LIBRARY_PATH=/ d" \
      -e '2 i export PATH="${host-PATH}:$PATH"'

    patchShebangs ./kevm
  '';

  makeFlags = [
    "INSTALL_PREFIX=${builtins.placeholder "out"}"
    "KEVM_RELEASE_TAG=v${version}"
    "SKIP_LLVM=true"
    "SKIP_HASKELL=true"
    "SYSTEM_LIBFF=true"
    "SYSTEM_LIBSECP256K1=true"
    "SYSTEM_LIBCRYPTOPP=true"
  ];

  preBuild = ''
    make plugin-deps "INSTALL_PREFIX=${builtins.placeholder "out"}"
  '';

  buildFlags = [ "build" ];
}
