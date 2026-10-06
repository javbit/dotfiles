{
  config.programs = {
    difftastic = {
      enable = true;
      git = {
        enable = true;
        diffToolMode = true;
      };
    };
    emacs.extraPackages = epkgs: with epkgs; [ difftastic ];
  };
}
