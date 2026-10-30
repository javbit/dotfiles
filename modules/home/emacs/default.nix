{
  pkgs,
  ...
}:

{
  imports = [
    ./darwin-quirks.nix
    ./ghostel.nix
    ./lisp.nix
    ./minimal-emacs.nix
    ./nix.nix
    ./ocaml.nix
    ./service.nix
  ];
  config = {
    programs.minimal-emacs.enable = true;
    programs.emacs = {
      enable = true;
      package = pkgs.my-emacs;
      extraPackages = epkgs: [ epkgs.treesit-grammars.with-all-grammars ];
    };
    services.emacs' = {
      enable = true;
      defaultEditor = true;
      executable = "Applications/Emacs.app/Contents/MacOS/Emacs";
    };
  };
}
