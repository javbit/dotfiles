{
  system.primaryUser = "javadmin";
  homebrew.enable = true;
  homebrew.casks = [
    "anki"
    "ghostty"
    "orion"
  ];
  nixpkgs.hostPlatform = "aarch64-darwin";
  nix.enable = false;
  system.stateVersion = 6;
}
