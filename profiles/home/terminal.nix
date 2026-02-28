{ pkgs, ... }:

{
  config = {
    programs.ghostty = {
      enable = true;
      package = null; # App managed by homebrew.
      enableZshIntegration = true;
      settings = {
        config-file = "config.custom";
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
