{ pkgs, ... }:

{
  config = {
    home.packages = with pkgs; [
      awscli2
      eza
      swi-prolog
      yt-dlp
      zmx

      my-agda # Keep Emacs mode & package together.
    ];
  };
}
