{
  mkShell,

  difftastic,
  helix,
  jujutsu
}:

mkShell {
  packages = [
    difftastic
    helix
    jujutsu
  ];
}
