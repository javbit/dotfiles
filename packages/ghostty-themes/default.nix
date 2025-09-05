{
  stdenvNoCC,
  fetchFromGitHub,
}:

stdenvNoCC.mkDerivation {
  name = "ghostty-themes";
  src = fetchFromGitHub {
    owner = "anhsirk0";
    repo = "ghostty-themes";
    rev = "f41cef8ebf79c79fa6485066a92d389a9e3fc186";
    hash = "sha256-/QE7ek+PezjwIm2JwPhm03oYoe7msadziWL80SGduGI=";
  };
  preInstall = ''
    mkdir "$out"
  '';
  postInstall = ''
    cp --recursive "$src/themes" "$out"
  '';
}
