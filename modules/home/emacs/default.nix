{
  inputs,
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
    ./service.nix
  ];
  config = {
    programs.minimal-emacs = {
      enable = true;
      source = inputs.minimal-emacs-d;
    };
    programs.emacs = {
      enable = true;
      package = pkgs.my-emacs;
    };
    services.emacs' = {
      enable = true;
      defaultEditor = true;
      executable = "Applications/Emacs.app/Contents/MacOS/Emacs";
    };
  };
}
