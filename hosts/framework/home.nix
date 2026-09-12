{ inputs, ... }:

{
  home-manager.backupFileExtension = "bak";
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
        ../../profiles/home/emacs.nix
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
          (import ../../packages/emacs/overlay-linux.nix)
          (import ../../packages/zmx/overlay.nix)
          (final: prev: {
            my-agda = final.agda.withPackages (p: [ p.standard-library ]);
          })
        ];
        home.stateVersion = "25.05";
      };
    };
}
