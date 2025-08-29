{
  config,
  ...
}:

{
  networking.computerName = "Jav’s MacBook Air";
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
    jav = { pkgs, ... }: {
      home.packages = with pkgs; [
        uutils-coreutils-noprefix
        uutils-diffutils
        uutils-findutils
      ];
      programs.zsh = {
        enable = true;
        autocd = true;
        autosuggestion.enable = true;
      };
      programs.helix = {
        enable = true;
        defaultEditor = true;
      };
      programs.git = {
        enable = true;
        userName = "Javed Mohamed";
        userEmail = "jav@deadbeef.moe";
        difftastic = {
          enable = true;
          enableAsDifftool = true;
        };
        ignores = [
          "*~"
          "*.swp"
          "result*"
          ".direnv"
        ];
      };
      programs.jujutsu = {
        enable = true;
        settings = {
          user = {
            name = "Javed Mohamed";
            email = "jav@deadbeef.moe";
          };
          ui.pager = ":builtin";
        };
      };
      home.stateVersion = "25.05";
    };
    javadmin = { pkgs, ... }: {
      home.packages = with pkgs; [];
      home.stateVersion = "25.05";
    };
  };
  homebrew.enable = true;
  homebrew.casks = [
    "anki"
    "ghostty"
    "mullvad-vpn"
    "orion"
    "signal"
  ];
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
