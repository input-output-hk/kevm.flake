name: inputs: final: prev: {
  inherit (let
    src = prev.stdenvNoCC.mkDerivation {
      name = "kore-src";
      src = "${inputs.k}/haskell-backend/src/main/native/haskell-backend";
      patches = [ "${inputs.self}/pkgs/0001-pass-in-haskell.nix.patch" ];
      dontBuild = true;
      dontCheck = true;
      installPhase = ''
        cp -r . $out
      '';
    };
  in
  import src {
    inherit src;
    pkgs = final;
  }) kore prelude-kore;

  llvm-backend = final.callPackage "${inputs.self}/pkgs/llvm-backend.nix" {
    src = "${inputs.k}/llvm-backend/src/main/native/llvm-backend";
  };

  k = final.callPackage "${inputs.self}/pkgs/k" {
    src = inputs.k;
    mavenix = import inputs.mavenix { pkgs = prev; };
  };

  ${name} = final.callPackage "${inputs.self}/pkgs/kevm.nix" {
    src = prev.stdenvNoCC.mkDerivation {
      name = "${name}-src";
      src = inputs.kevm;
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
