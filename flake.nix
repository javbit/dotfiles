{
  description = "Jav's system configurations";

  inputs = {
    nixpkgs.url = "https://flakehub.com/f/NixOS/nixpkgs/0.2605";
    nix-darwin.url = "https://flakehub.com/f/nix-darwin/nix-darwin/0.2605";
    nix-darwin.inputs.nixpkgs.follows = "nixpkgs";
    home-manager.url = "github:nix-community/home-manager/release-26.05";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
    emacs-overlay = {
      url = "github:nix-community/emacs-overlay";
      inputs = {
        nixpkgs.follows = "nixpkgs";
        nixpkgs-stable.follows = "nixpkgs";
      };
    };
  };

  outputs =
    inputs@{
      self,
      nixpkgs,
      nix-darwin,
      home-manager,
      emacs-overlay,
    }:
    let
      forAllSystems =
        f:
        nixpkgs.lib.genAttrs [
          "aarch64-darwin"
        ] (system: f nixpkgs.legacyPackages.${system});
    in
    {
      overlays = {
        ghostty-themes = import ./packages/ghostty-themes/overlay.nix;
        zmx = import ./packages/zmx/overlay.nix;
        emacs = nixpkgs.lib.composeManyExtensions [
          emacs-overlay.overlays.default
          (import ./packages/emacs/overlay.nix)
        ];
      };

      packages = forAllSystems (pkgs: {
        ghostty-themes = pkgs.callPackage ./packages/ghostty-themes/default.nix { };
        zmx = pkgs.callPackage ./packages/zmx/default.nix { };
        my-emacs = (pkgs.extend emacs-overlay.overlays.default).callPackage ./packages/emacs/my-emacs.nix { };
      });

      devShells = forAllSystems (pkgs: {
        default = pkgs.callPackage ./shell.nix { };
      });

      darwinConfigurations."Javs-MacBook-Air" = nix-darwin.lib.darwinSystem {
        specialArgs = { inherit inputs; };
        modules = [
          ./configuration.nix
          home-manager.darwinModules.default
        ];
      };
    };
}
