{
  description = "kevm package";

  inputs = {
    nixpkgs.follows = "haskellNix/nixpkgs-unstable";
    haskellNix.url = "github:input-output-hk/haskell.nix";

    kevm.url = "github:kframework/evm-semantics/v1.0.1-63dda59";
    kevm.flake = false;

    k.url = "https://github.com/kframework/k?ref=v5.2.13";
    k.type = "git";
    k.flake = false;
    k.submodules = true;

    mavenix.url = "github:jonringer/mavenix/add-flakes";
    mavenix.flake = false;

    blockchain-plugin.url = "https://github.com/runtimeverification/blockchain-k-plugin?rev=cc7384e565e4c8df4d17a3330cd9951d32d4830f";
    blockchain-plugin.type = "git";
    blockchain-plugin.flake = false;
    blockchain-plugin.submodules = true;
  };

  outputs = inputs@{ self, nixpkgs, haskellNix, ... }:
    let
      pkgs = import nixpkgs { inherit system; overlays = [ overlay haskellNix.overlay ]; };

      system = "x86_64-linux";

      name = "KEVM";

      overlay = import ./overlay.nix name inputs;
    in
    {
      inherit overlay;

      packages.${system} = self.overlay pkgs nixpkgs.legacyPackages.${system};

      legacyPackages.${system} = pkgs;

      defaultPackage.${system} = self.packages.${system}.${name};
    };
}
