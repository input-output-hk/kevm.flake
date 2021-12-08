name: inputs: final: prev:
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

  ${name} = final.callPackage "${inputs.self}/pkgs/kevm.nix" {
    src = prev.stdenvNoCC.mkDerivation {
      name = "${name}-src";
      src = inputs.kevm;
      patches = [ pkgs/make.patch ];
      dontBuild = true;
      dontCheck = true;
      installPhase = ''
        cp -r . $out
        cd $out

        rm -rf deps/{k, plugin}

        cp -r ${inputs.k}/ -T deps/k
        cp -r ${inputs.blockchain-plugin}/ -T deps/plugin
      '';
    };
  };

}
