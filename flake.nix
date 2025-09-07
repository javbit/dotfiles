{
  description = "Jav's system configurations";

  inputs = {
    nixpkgs.url = "https://flakehub.com/f/NixOS/nixpkgs/0.2505";
    nix-darwin.url = "https://flakehub.com/f/nix-darwin/nix-darwin/0.2505";
    nix-darwin.inputs.nixpkgs.follows = "nixpkgs";
    home-manager.url = "github:nix-community/home-manager/release-25.05";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
    emacs-overlay = {
      url = "github:nix-community/emacs-overlay";
      inputs = {
        nixpkgs.follows = "nixpkgs";
        nixpkgs-stable.follows = "nixpkgs";
      };
    };
  };

  outputs = inputs @ { self, nixpkgs, nix-darwin, home-manager, emacs-overlay }:
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
        specialArgs = { inherit inputs; };
        modules = [
          ./configuration.nix
          home-manager.darwinModules.default
        ];
      };
    }
  ;
}
