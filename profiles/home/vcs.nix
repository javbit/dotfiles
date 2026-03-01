{ config, lib, ... }:

{
  config = {
    programs.helix.enable = true;
    programs.git = {
      enable = true;
      settings = {
        user = {
          name = "Javed Mohamed";
          email = "jav@deadbeef.moe";
        };
      };
      ignores = [
        "*~"
        "*.swp"
        "result*"
        ".direnv"
      ];
    };
    programs.difftastic = {
      enable = true;
      git = {
        enable = true;
        diffToolMode = true;
      };
    };
    programs.mergiraf.enable = true;
    programs.jujutsu = {
      enable = true;
      settings = {
        user = {
          name = "Javed Mohamed";
          email = "jav@deadbeef.moe";
        };
        aliases = {
          tug = [
            "bookmark"
            "move"
            "--from"
            "heads(::@- & bookmarks())"
            "--to"
            "@-"
          ];
        };
        ui.pager = ":builtin";
        ui.editor = "hx";
        ui.diff-formatter = [
          (lib.meta.getExe config.programs.difftastic.package)
          "--color=always"
          "$left"
          "$right"
        ];
      };
    };
  };
}
