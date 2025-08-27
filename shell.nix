{
  mkShell,

  difftastic,
  helix,
  jujutsu,
  just
}:

mkShell {
  packages = [
    difftastic
    helix
    jujutsu
    just
  ];
}
