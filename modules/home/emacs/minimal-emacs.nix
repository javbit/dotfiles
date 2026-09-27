{
  config,
  lib,
  ...
}:
let
  inherit (lib)
    mkEnableOption
    mkIf
    mkOption
    types
    ;

  cfg = config.programs.minimal-emacs;

  # Files minimal-emacs.d loads from its own directory, when they exist.
  userFiles = [
    "pre-early-init.el"
    "post-early-init.el"
    "pre-init.el"
    "post-init.el"
  ];

  # Out-of-store, so edits in the checkout apply without a rebuild.
  linkUser = path: config.lib.file.mkOutOfStoreSymlink "${cfg.userDirectory}/${path}";
in
{
  options.programs.minimal-emacs = {
    enable = mkEnableOption "minimal-emacs.d as the base Emacs configuration in ~/.config/emacs";

    source = mkOption {
      type = types.path;
      description = ''
        Pinned checkout of minimal-emacs.d. Its {file}`early-init.el` and
        {file}`init.el` are linked read-only; upstream says never to edit them.
      '';
    };

    userDirectory = mkOption {
      type = types.str;
      default = "${config.home.homeDirectory}/Sources/emacs.d";
      defaultText = lib.literalExpression ''"''${config.home.homeDirectory}/Sources/emacs.d"'';
      description = ''
        Mutable checkout holding the pre/post init files and {file}`lisp/`.
        Missing files are skipped by minimal-emacs.d, so Emacs still starts
        before this is cloned.
      '';
    };
  };

  config = mkIf cfg.enable {
    xdg.configFile = {
      "emacs/early-init.el".source = "${cfg.source}/early-init.el";
      "emacs/init.el".source = "${cfg.source}/init.el";
      "emacs/lisp".source = linkUser "lisp";
    }
    // lib.listToAttrs (map (f: lib.nameValuePair "emacs/${f}" { source = linkUser f; }) userFiles);

    # Emacs only reads ~/.config/emacs when none of these exist.
    home.activation.minimalEmacsShadowed = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
      for f in "$HOME/.emacs" "$HOME/.emacs.el" "$HOME/.emacs.d"; do
        if [ -e "$f" ]; then
          warnEcho "minimal-emacs: $f takes precedence over ${config.xdg.configHome}/emacs"
        fi
      done
    '';
  };
}
