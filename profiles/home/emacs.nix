{
  inputs,
  pkgs,
  ...
}:

{
  imports = [
    ../../modules/home/emacs/minimal-emacs.nix
    ../../modules/home/emacs/darwin-quirks.nix
    ../../modules/home/services/emacs.nix
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
