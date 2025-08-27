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
  home-manager.users = {
    jav = { pkgs, ... }: {
      home.packages = with pkgs; [
        uutils-coreutils-noprefix
        uutils-diffutils
        uutils-findutils
      ];
      programs.helix = {
        enable = true;
        defaultEditor = true;
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
  nixpkgs.hostPlatform = "aarch64-darwin";
  nix.enable = false;
  system.stateVersion = 6;
}
