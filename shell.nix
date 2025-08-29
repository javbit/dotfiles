{
  mkShell,

  difftastic,
  just,
}:

mkShell {
  packages = [
    difftastic
    just
  ];
}
