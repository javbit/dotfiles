{
  config.programs = {
    direnv = {
      enable = true;
      nix-direnv.enable = true;
    };
    emacs.extraPackages = epkgs: with epkgs; [ envrc ];
  };
}
