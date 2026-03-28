{ pkgs, ... }:

{
  config = {
    home.packages = with pkgs; [
      awscli2
      eza
      yt-dlp
      zmx

      my-agda # Keep Emacs mode & package together.
    ];
  };
}
