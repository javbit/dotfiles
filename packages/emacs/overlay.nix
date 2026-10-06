final: prev:

{
  my-emacs =
    if final.stdenv.hostPlatform.isDarwin then
      prev.callPackage ./my-emacs.nix { }
    else
      prev.emacs-git-pgtk.override {
        withTreeSitter = true;
        withNativeCompilation = true;
      };
}
