{
  config = {
    programs.emacs.extraPackages = epkgs: [ epkgs.nix-ts-mode ];
  };
}
