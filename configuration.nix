{
  homebrew.casks = [
    "orion"
  ];
  nixpkgs.hostPlatform = "aarch64-darwin";
  nix.enable = false;
  system.stateVersion = 6;
}
