{
  my-emacs,
  emacsPackagesFor,
}:

(emacsPackagesFor my-emacs).emacsWithPackages (epkgs: with epkgs; [
  # Themes:
  standard-themes
  doric-themes
  modus-themes
  ef-themes

  # Modes (major & minor)
  ## Lisp
  paredit
  paren-face
  ## Nix
  nix-ts-mode

  # Treesitter
  treesit-grammars.with-all-grammars
  tree-sitter-langs
])
