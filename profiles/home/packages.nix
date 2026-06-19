{ pkgs, ... }:

{
  config = {
    home.packages = with pkgs; [
      awscli2
      eza
      swi-prolog
      scryer-prolog
      yt-dlp
      zmx

      nixos-rebuild

      my-agda # Keep Emacs mode & package together.
    ];
  };
}
