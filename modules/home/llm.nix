{ pkgs, ... }:

{
  config = {
    home.packages = [ pkgs.pi-coding-agent ];
    programs.emacs.extraPackages = epkgs: with epkgs; [ pi-coding-agent ];
  };
}
