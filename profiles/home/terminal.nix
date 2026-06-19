{ pkgs, ... }:

{
  config = {
    programs.ghostty = {
      enable = true;
      # On darwin the app is managed by homebrew; on Linux let home-manager
      # install and manage it (including the systemd user service).
      package = if pkgs.stdenv.isDarwin then null else pkgs.ghostty;
      enableZshIntegration = true;
      settings = {
        config-file = "?config.custom";
      };
    };
    xdg.configFile."ghostty/themes" = {
      enable = true;
      force = true;
      recursive = true;
      source = "${pkgs.ghostty-themes}/themes";
    };
    programs.aria2.enable = true;
  };
}
