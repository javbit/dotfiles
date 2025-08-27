{
  networking.computerName = "Jav’s MacBook Air";
  networking.hostName = "Javs-MacBook-Air";
  system.primaryUser = "javadmin";
  homebrew.enable = true;
  homebrew.casks = [
    "anki"
    "ghostty"
    "orion"
    "signal"
  ];
  programs.direnv.enable = true;
  nixpkgs.hostPlatform = "aarch64-darwin";
  nix.enable = false;
  system.stateVersion = 6;
}
