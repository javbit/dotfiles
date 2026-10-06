{
  config = {
    programs.emacs.extraPackages = epkgs: with epkgs; [
      paredit
    ];
  };
}
