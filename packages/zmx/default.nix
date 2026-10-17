{
  stdenvNoCC,
  fetchzip,
}:

let
  srcs = {
    "aarch64-linux" = fetchzip {
      url = "https://zmx.sh/a/zmx-0.8.1-linux-aarch64.tar.gz";
      hash = "sha256-Ysds/CVZpsZyXp2BJV5RcQjgHOgBte1GYvgHMUnf+UY=";
    };
    "x86_64-linux" = fetchzip {
      url = "https://zmx.sh/a/zmx-0.8.1-linux-x86_64.tar.gz";
      hash = "sha256-szjgt6wMqNNIj7g17cikmfMshEyDLKUu+uNhA6gzJcA=";
    };
    "aarch64-darwin" = fetchzip {
      url = "https://zmx.sh/a/zmx-0.8.1-macos-aarch64.tar.gz";
      hash = "sha256-YVstzEzShrsJBQA+DdbpkugB96GdrbxA8yHcyyOyRUI=";
    };
    "x86_64-darwin" = fetchzip {
      url = "https://zmx.sh/a/zmx-0.8.1-macos-x86_64.tar.gz";
      hash = "sha256-dLSH0+92VxPG5Bue5xHA6EjAwOuuYzHeM7kFcI3yLEo=";
    };
  };
in

stdenvNoCC.mkDerivation {
  pname = "zmx";
  version = "0.8.1";
  src = srcs.${stdenvNoCC.hostPlatform.system};

  dontBuild = true;

  installPhase = ''
    mkdir --parents $out/bin
    cp zmx $out/bin/
  '';

  meta = {
    description = "Session persistence for terminal processes.";
    homepage = "https://zmx.sh";
    platforms = builtins.attrNames srcs;
    mainProgram = "zmx";
  };
}
