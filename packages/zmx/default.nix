{
  stdenvNoCC,
  fetchzip,
}:

let
  srcs = {
    "aarch64-linux" = fetchzip {
      url = "https://zmx.sh/a/zmx-0.4.2-linux-aarch64.tar.gz";
      hash = "sha256-ApYRHf05XDo1VGOB5JmItcbSCCxom4rTVM4gwQ8d0qE=";
    };
    "x86_64-linux" = fetchzip {
      url = "https://zmx.sh/a/zmx-0.4.2-linux-x86_64.tar.gz";
      hash = "sha256-lka/9yC4e7TtluukTizCbShSHkxkCOBlFkEzq6Ys/As=";
    };
    "aarch64-darwin" = fetchzip {
      url = "https://zmx.sh/a/zmx-0.4.2-macos-aarch64.tar.gz";
      hash = "sha256-WeFtmUsbG3QVV2rVOFTooj8YNdhtBeezrhlHjhcx6mo=";
    };
    "x86_64-darwin" = fetchzip {
      url = "https://zmx.sh/a/zmx-0.4.2-macos-x86_64.tar.gz";
      hash = "sha256-Pho8MDqBrDgrK5bc7f7+GS1ctpxzoxj+z5fu0AONwUc=";
    };
  };
in

stdenvNoCC.mkDerivation {
  pname = "zmx";
  version = "0.4.2";
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
