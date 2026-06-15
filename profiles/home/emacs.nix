{
  pkgs,
  ...
}:

{
  imports = [
    ../../modules/home/services/emacs.nix
  ];
  config = {
    programs.emacs = {
      enable = true;
      package = pkgs.my-emacs;
      extraPackages =
        epkgs: with epkgs; [
          # Environment management
          exec-path-from-shell
          envrc

          # VCS
          vc-jj

          # Themes
          standard-themes
          doric-themes
          modus-themes
          ef-themes

          # Help
          which-key

          # LISP Programming
          paredit
          paren-face

          # Nix
          nix-ts-mode

          # Haskell
          haskell-mode
          haskell-ts-mode

          # Prolog
          prolog-mode # Stefan Bruda's prolog.el
          ediprolog

          # LSP
          eglot

          # Motion
          avy

          # LLMs
          gptel

          # Completion
          corfu
          vertico
          orderless
          marginalia

          # Utilities
          eat
          tempel
          olivetti

          # Treesitter
          treesit-grammars.with-all-grammars
          tree-sitter-langs
        ];
    };
    services.emacs' = {
      enable = true;
      defaultEditor = true;
      executable = "Applications/Emacs.app/Contents/MacOS/Emacs";
    };
  };
}
