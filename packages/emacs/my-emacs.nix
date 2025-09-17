{
  emacs-git-pgtk,

  fetchFromGitHub,
  fetchpatch,
}:

let
  emacs-icons = fetchFromGitHub {
    owner = "jimeh";
    repo = "emacs-liquid-glass-icons";
    tag = "v1.0.1";
    hash = "sha256-dapzrfbkVyzBtv8FLhNBsS6XOmxqMUbEhcgQEa7LzrM=";
  };

  patches.round-undecorated-frame = fetchpatch {
    url = "https://github.com/d12frosted/homebrew-emacs-plus/raw/refs/heads/master/patches/emacs-31/round-undecorated-frame.patch";
    hash = "sha256-WWLg7xUqSa656JnzyUJTfxqyYB/4MCAiiiZUjMOqjuY=";
  };
  patches.system-appearance = fetchpatch {
    url = "https://github.com/d12frosted/homebrew-emacs-plus/raw/refs/heads/master/patches/emacs-31/system-appearance.patch";
    hash = "sha256-4+2U+4+2tpuaThNJfZOjy1JPnneGcsoge9r+WpgNDko=";
  };
  patches.liquid-glass-icon = ./liquid-glass-icon.patch;

  my-emacs = emacs-git-pgtk.override {
    withTreeSitter = true;
    withNativeCompilation = true;
  };
  my-emacs' = my-emacs.overrideAttrs (old: {
    patches = old.patches or [] ++ builtins.attrValues patches;
    postFixup = old.postFixup or "" + ''
      cp ${emacs-icons}/Resources/Assets.car $out/Applications/Emacs.app/Contents/Resources/
    '';
  });
in

my-emacs'
