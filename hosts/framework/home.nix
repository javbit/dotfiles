{ inputs, ... }:

{
  home-manager.backupFileExtension = "bak";
  home-manager.extraSpecialArgs = { inherit inputs; };
  home-manager.users.root =
    _:
    {
      imports = [
        ../../profiles/home/shells.nix
      ];
      home.stateVersion = "25.05";
    };
  home-manager.users.jav =
    { pkgs, ... }:
    {
      imports = [
        ../../modules/home/emacs
        ../../profiles/home/shells.nix
        ../../profiles/home/vcs.nix
        ../../profiles/home/terminal.nix
        ../../profiles/home/packages.nix
        ../../profiles/home/niri.nix
        ../../profiles/home/cursor.nix
        ../../profiles/home/sdr.nix
      ];
      config = {
        home.packages = [ pkgs.tor-browser ];
        nixpkgs.overlays = [
          inputs.emacs-overlay.overlays.default
          (import ../../packages/ghostty-themes/overlay.nix)
          (import ../../packages/emacs/overlay.nix)
          (import ../../packages/zmx/overlay.nix)
        ];
        home.stateVersion = "25.05";
      };
    };
}
