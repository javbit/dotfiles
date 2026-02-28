{ pkgs, ... }:

{
  config = {
    home.packages = with pkgs; [
      awscli2
      eza
      yt-dlp

      my-agda # Keep Emacs mode & package together.
    ];
  };
}
