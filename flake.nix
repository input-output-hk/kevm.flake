{
  description = "kevm package";

  inputs = {
    "haskell.nix".url = "github:input-output-hk/haskell.nix";
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-21.05";
    mavenix.url = "github:nix-community/mavenix";
    mavenix.flake = false;
    kframework.url = "https://github.com/kreisys/k";
    kframework.type = "git";
    kframework.submodules = true;
    kevm.url = "https://github.com/nrdxp/evm-semantics";
    kevm.flake = false;
    kevm.type = "git";
    kevm.ref = "nix-package";
    kevm.submodules = true;
  };

  outputs = inputs@{ self, kevm, nixpkgs, ... }:
    let
      system = "x86_64-linux";
      overlay = final: prev: {
        inherit (import kevm { inherit inputs; inherit (final) kframework pkgs; }) kevm;
        kframework = import inputs.kframework { inherit (prev) system; release = true; };
      };
      pkgs = import nixpkgs { inherit system; overlays = [ overlay ]; };
    in
    {
      inherit overlay;

      packages.${system}.kevm = pkgs.kevm;

      defaultPackage.${system} = self.packages.${system}.kevm;

    };
}
