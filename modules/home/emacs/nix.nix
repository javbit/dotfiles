{
  config = {
    programs.emacs.extraPackages = epkgs: [
      epkgs.nix-ts-mode
      (epkgs.treesit-grammars.with-grammars (g: [
        g.tree-sitter-nix
        g.tree-sitter-json      # Builtin mode, flake.lock
      ]))
    ];
  };
}
