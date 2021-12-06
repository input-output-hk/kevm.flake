{ cryptopp
, jemalloc
, k
, kore
, lib
, libff
, libffi
, libyamlcpp
, llvm-backend
, mpfr
, openjdk
, openssl
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

  host-PATH = lib.makeBinPath [ k llvm-backend kore ];
in
stdenv.mkDerivation {
  pname = "kevm";
  inherit version src;

  nativeBuildInputs = [
    llvm-backend.passthru.clang
    k
    kore
    libyamlcpp
    llvm-backend
    mpfr
    openjdk
    openssl
    procps
    protobuf
    python
    which
    z3
  ] ++ llvm-backend.nativeBuildInputs;

  dontUseCmakeConfigure = true;

  postPatch = ''
    sed -i kevm \
      -e "/^export LD_LIBRARY_PATH=/ d" \
      -e '2 i export PATH="${host-PATH}:$PATH"'

    patchShebangs ./kevm
  '';

  makeFlags = [
    # "INSTALL_PREFIX=${builtins.placeholder "out"}"
    "SKIP_LLVM=true"
    "SKIP_HASKELL=true"
    "SYSTEM_LIBFF=true"
    "SYSTEM_LIBSECP256K1=true"
    "SYSTEM_LIBCRYPTOPP=true"
  ];

  NIX_CFLAGS_COMPILE = [ "-Wno-unused-command-line-argument" ];

  preBuild = ''
    make plugin-deps
  '';

  buildFlags = [ "build" ];
}
