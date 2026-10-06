{
  lib,
  pkgs,
  ...
}:

{
  config = lib.mkIf pkgs.stdenv.isLinux {
    programs.emacs.extraPackages = epkgs: [ epkgs.ghostel ];
  };
}
