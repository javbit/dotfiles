{ config, lib, ... }:

{
  config = {
    programs.git = {
      enable = true;
      settings = {
        user = {
          name = "Javed Mohamed";
          email = "jav@deadbeef.moe";
        };
        pack = {
          threads = 0;
          windowMemory = "5G";
          packSizeLimit = "2G";
        };
        gc.auto = 8000;
        core = {
          whitespace = "space-before-tab,trailing-space";
          preloadindex = true;
        };
        push = {
          default = "current";
          autoSetupRemote = true;
          followTags = true;
        };
        rerere = {
          enabled = true;
          autoUpdate = true;
        };
        log.date = "iso";
      };
      ignores = [
        "*~"
        "*.swp"
        "result*"
        ".direnv"
      ];
    };
    programs.gh.enable = true;
    programs.difftastic = {
      enable = true;
      git = {
        enable = true;
        diffToolMode = true;
      };
    };
    programs.emacs.extraPackages = epkgs: [ epkgs.difftastic ];
    programs.mergiraf = {
      enable = true;
      enableGitIntegration = true;
      enableJujutsuIntegration = true;
    };
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
        ui.editor = "emacsclient";
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
