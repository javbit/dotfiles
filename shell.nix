{
  mkShell,

  difftastic,
  jujutsu,
  just
}:

mkShell {
  packages = [
    difftastic
    jujutsu
    just
  ];
}
