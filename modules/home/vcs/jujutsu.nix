{
  config,
  lib,
  pkgs,
  ...
}:

let
  jj-prek = pkgs.writeShellApplication {
    name = "jj-prek";
    text = ''
      usage() {
        echo "usage: jj prek start <REVISION> | jj prek resume" >&2
        exit 2
      }

      case "''${1:-}" in
        start)
          [ $# -eq 2 ] || usage
          jj new "$2"
          ;;
        resume)
          [ $# -eq 1 ] || usage
          if [ "$(jj log --revision @ --no-graph --template empty)" != true ]; then
            echo "jj prek: @ has changes; squash or abandon them first" >&2
            exit 1
          fi
          ;;
        *) usage ;;
      esac

      while true; do
        prek --last-commit --verbose && jj next --no-edit || exit 1
      done
    '';
  };
in
{
  config.programs.jujutsu = {
    enable = true;
    settings = {
      inherit (config.programs.git.settings) user;
      aliases = {
        tug = [ "bookmark" "move" "--from" "heads(::@- & bookmarks())" "--to" "@-" ];
        prek = [ "util" "exec" "--" (lib.meta.getExe jj-prek) ];
      };
      revset-aliases = {
        "pr(b)" = "(::b- & (bookmarks() | trunk()))..b";
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
