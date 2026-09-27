{ pkgs, ... }:

{
  config = {
    home.packages = with pkgs; [
      zmx

      nixos-rebuild
    ];
  };
}
