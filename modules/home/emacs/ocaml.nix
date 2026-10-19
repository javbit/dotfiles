{
  config = {
    programs.emacs.extraPackages = epkgs: [
      epkgs.neocaml
      (epkgs.treesit-grammars.with-grammars (g: [
        g.tree-sitter-ocaml
        g.tree-sitter-ocaml-interface   # .mli files
      ]))
    ];
  };
}
