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
      pkgs = nixpkgs.legacyPackages.x86_64-linux;
      kframework = import inputs.kframework { system = "x86_64-linux"; release = true; };
    in
    {

      packages.x86_64-linux.kevm = (import kevm { inherit inputs pkgs kframework; }).kevm;

      defaultPackage.x86_64-linux = self.packages.x86_64-linux.kevm;

    };
}
