{
  config = {
    programs.emacs.extraPackages = epkgs: [ epkgs.neocaml ];
  };
}
