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
  system.primaryUser = config.users.users.jav.name;
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
            (import ./packages/zmx/overlay.nix)
            (final: prev: {
              # test_make_tmpdir writes to /tmp, which the Darwin sandbox denies.
              nixos-rebuild-ng = prev.nixos-rebuild-ng.overrideAttrs (old: {
                disabledTests = (old.disabledTests or [ ]) ++ [ "test_make_tmpdir" ];
              });
            })
          ];
          home.stateVersion = "25.05";
        };
      };
    javadmin =
      { ... }:
      {
        # Enough to make the monthly config edit tolerable: jj, git, helix.
        imports = [ ./profiles/home/vcs.nix ];
        programs.zsh = {
          enable = true;
          autocd = true;
          autosuggestion.enable = true;
          envExtra = ''
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
  # jav is a standard user with Touch ID sudo for a fixed set of system
  # management commands. The config repo is owned by javadmin, so this rule
  # applies a configuration jav cannot modify.
  #
  # always_set_home: macOS keeps HOME through sudo by default. darwin-rebuild
  # puts $HOME/.nix-profile/bin on PATH and nix reads $HOME/.config/nix, so
  # root must not inherit jav's HOME.
  # secure_path: used for command lookup and the child's PATH; every entry is
  # a root-owned directory.
  security.sudo.extraConfig = ''
    Defaults:jav always_set_home
    Defaults:jav secure_path="/run/current-system/sw/bin:/nix/var/nix/profiles/default/bin:/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin"

    Cmnd_Alias SYSMGMT = \
      /run/current-system/sw/bin/darwin-rebuild switch --flake /Users/javadmin/Sources/dotfiles, \
      /run/current-system/sw/bin/darwin-rebuild switch --rollback, \
      /usr/local/bin/determinate-nixd upgrade, \
      /nix/var/nix/profiles/default/bin/nix-collect-garbage --delete-older-than 14d, \
      /nix/var/nix/profiles/default/bin/nix store optimise

    jav ALL=(root) SYSMGMT
  '';
  nixpkgs.hostPlatform = "aarch64-darwin";
  nix.enable = false;
  system.stateVersion = 6;
}
