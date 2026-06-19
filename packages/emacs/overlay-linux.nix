final: prev:

{
  my-emacs = prev.emacs-git-pgtk.override {
    withTreeSitter = true;
    withNativeCompilation = true;
  };
}
