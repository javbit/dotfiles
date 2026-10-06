{
  config.programs.git = {
    enable = true;
    settings = {
      pack = {
        threads = 0;
        windowMemory = "5G";
        packSizeLimit = "2G";
      };
      gc.auto = 8000;
      core = {
        whitespace = "space-before-tab,trailing-space";
        preloadindex = true;
      };
      push = {
        default = "current";
        autoSetupRemote = true;
        followTags = true;
      };
      rerere = {
        enabled = true;
        autoUpdate = true;
      };
      log.date = "iso";
    };
    ignores = [
      "*~"
      "*.swp"
      "result*"
      ".direnv"
    ];
  };
}
