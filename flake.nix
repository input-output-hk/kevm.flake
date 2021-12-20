{
  description = "kevm package";

  inputs = {
    nixpkgs.follows = "haskellNix/nixpkgs-unstable";
    haskellNix.url = "github:input-output-hk/haskell.nix";

    kevm.url = "github:kframework/evm-semantics/v1.0.1-fc35db2";
    kevm.flake = false;

    k = {
      flake = false;
      submodules = true;
      type = "git";
      url = "https://github.com/kframework/k?ref=v5.2.43";
    };

    mavenix.url = "github:nix-community/mavenix";
    mavenix.flake = false;

    # use rev set in `kevm`'s '.gitmodule' file (update on change)
    blockchain-plugin.url = "https://github.com/runtimeverification/blockchain-k-plugin?rev=640c5919710b64a643563523db2e2a36a656ce06";
    blockchain-plugin.type = "git";
    blockchain-plugin.flake = false;
    blockchain-plugin.submodules = true;

    utils.url = "github:numtide/flake-utils";
  };

  outputs = inputs@{ self, nixpkgs, haskellNix, utils, ... }:
    let
      pname = "KEVM";

      overlay = import ./overlay.nix pname inputs;
    in
    {
      inherit overlay;

    } // utils.lib.eachDefaultSystem (system:
      let
        pkgs = import nixpkgs {
          inherit system; overlays = [ overlay haskellNix.overlay ];
        };
      in
      {
        packages =
          self.overlay
            pkgs
            nixpkgs.legacyPackages.${system};

        legacyPackages = pkgs;

        defaultPackage = self.packages.${system}.${pname};
      });
}
