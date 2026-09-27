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
    };
    services.emacs' = {
      enable = true;
      defaultEditor = true;
      executable = "Applications/Emacs.app/Contents/MacOS/Emacs";
    };
  };
}
