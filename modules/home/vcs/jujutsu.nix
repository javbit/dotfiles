{
  config,
  lib,
  pkgs,
  ...
}:

{
  config.programs.jujutsu = {
    enable = true;
    settings = {
      inherit (config.programs.git.settings) user;
      aliases = {
        tug = [ "bookmark" "move" "--from" "heads(::@- & bookmarks())" "--to" "@-" ];
      };
      ui = {
        pager = ":builtin";
        editor = if config.programs.emacs.enable then "emacsclient" else lib.meta.getExe pkgs.nano;
        diff-formatter = [
          (lib.meta.getExe config.programs.difftastic.package)
          "--color=always"
          "$left"
          "$right"
        ];
      };
    };
  };
}
