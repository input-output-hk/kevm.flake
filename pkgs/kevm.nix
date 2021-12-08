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
, src
, stdenv
, which
, version
}:

let
  inherit (llvm-backend.passthru) clang lld;

  host-PATH = lib.makeBinPath [ k llvm-backend kore ];
in
stdenv.mkDerivation {
  pname = "kevm";
  inherit version src;

  nativeBuildInputs = [ protobuf k llvm-backend clang cmake which openssl pkgconfig procps kore lld ];
  buildInputs = [ cryptopp libff mpfr secp256k1 ];

  dontConfigure = true;
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
