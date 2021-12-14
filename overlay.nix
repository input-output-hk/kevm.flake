pname: inputs: final: prev:
let
  mavenix = import inputs.mavenix { pkgs = prev; };

  koreProject =
    let
      src = "${inputs.k}/haskell-backend/src/main/native/haskell-backend";
      srcNix = (prev.stdenvNoCC.mkDerivation {
        inherit src;

        name = "kore-src";
        patches = [ "${inputs.self}/pkgs/0001-pass-in-haskell.nix.patch" ];
        dontBuild = true;
        dontCheck = true;
        installPhase = ''
          cp -r . $out
        '';
      });
    in
    import srcNix { inherit src; pkgs = final; };

in
{
  inherit (koreProject) kore prelude-kore;

  llvm-backend = final.callPackage "${inputs.self}/pkgs/llvm-backend.nix" {
    src = "${inputs.k}/llvm-backend/src/main/native/llvm-backend";
  };

  k = final.callPackage "${inputs.self}/pkgs/k" {
    src = inputs.k;
    inherit mavenix;
  };

  libff = final.callPackage "${inputs.self}/pkgs/libff.nix" {
    inherit (final.llvmPackages_12) stdenv;
    src = "${inputs.blockchain-plugin}/deps/libff";
  };

  mavenix = mavenix.cli;

  ${pname} = final.callPackage "${inputs.self}/pkgs/kevm.nix" {
    inherit pname inputs;
    version = "1.0.1-${inputs.kevm.shortRev}";
    patches = [ pkgs/0001-fix-cmake-and-makefile-for-nix.patch ];
  };
}
