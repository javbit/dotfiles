{
  description = "Jav's system configurations";

  inputs = {
    nixpkgs.url = "https://flakehub.com/f/NixOS/nixpkgs/0.2505";
    nix-darwin.url = "https://flakehub.com/f/nix-darwin/nix-darwin/0.2505";
    nix-darwin.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = { self, nixpkgs, nix-darwin }:
    let
      forAllSystems = f:
        nixpkgs.lib.genAttrs [
          "aarch64-darwin"
        ] (system: f nixpkgs.legacyPackages.${system});
    in {
      devShells = forAllSystems (pkgs: {
        default = pkgs.callPackage ./shell.nix {};
      });

      darwinConfigurations."Javs-MacBook-Air" = nix-darwin.lib.darwinSystem {
        modules = [ ./configuration.nix ];
      };
    }
  ;
}
