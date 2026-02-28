{
  inputs,
  config,
  lib,
  ...
}:

{
  imports = [
    ./profiles/darwin/homebrew.nix
  ];
  networking.computerName = "Jav's MacBook Air";
  networking.hostName = "Javs-MacBook-Air";
  users.users = {
    # Normal account.
    jav = {
      description = "Javed Mohamed";
      home = "/Users/jav";
    };
    # Admin account.
    javadmin = {
      description = "Javed Mohamed (Admin)";
      home = "/Users/javadmin";
    };
  };
  system.primaryUser = config.users.users.javadmin.name;
  home-manager.backupFileExtension = "bak";
  home-manager.users = {
    jav =
      {
        config,
        osConfig,
        pkgs,
        ...
      }:
      {
        imports = [
          ./profiles/home/emacs.nix
          ./profiles/home/shells.nix
          ./profiles/home/vcs.nix
          ./profiles/home/terminal.nix
          ./profiles/home/packages.nix
        ];
        config = {
          # TODO: Inherit the OS's nixpkgs.
          nixpkgs.overlays = [
            inputs.emacs-overlay.overlays.default
            (import ./packages/ghostty-themes/overlay.nix)
            (import ./packages/emacs/overlay.nix)
            (final: prev: {
              my-agda = final.agda.withPackages (p: [ p.standard-library ]);
            })
          ];
          home.stateVersion = "25.05";
        };
      };
    javadmin =
      { ... }:
      {
        programs.zsh = {
          enable = true;
          autocd = true;
          autosuggestion.enable = true;
          envExtra = ''
            eval $(/opt/homebrew/bin/brew shellenv)
            export TERMINFO=/Applications/Ghostty.app/Contents/Resources/terminfo
          '';
        };
        home.stateVersion = "25.05";
      };
  };
  environment.systemPath = [
    "/opt/homebrew/bin"
  ];
  programs.fish.enable = true;
  programs.direnv.enable = true;
  security.pam.services.sudo_local = {
    enable = true;
    touchIdAuth = true;
    watchIdAuth = true;
  };
  nixpkgs.hostPlatform = "aarch64-darwin";
  nix.enable = false;
  system.stateVersion = 6;
}
