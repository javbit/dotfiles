{
  lib,
  pkgs,
  ...
}:

{
  config = lib.mkIf pkgs.stdenv.isDarwin {
    # launchd starts the daemon without the login shell's environment, so
    # PATH lacks Nix profiles and Homebrew. On Linux the systemd unit already
    # wraps Emacs in a login shell.
    programs.emacs.extraPackages = epkgs: [ epkgs.exec-path-from-shell ];
  };
}
