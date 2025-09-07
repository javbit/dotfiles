{
  emacs-git-pgtk,

  fetchzip,
  fetchpatch,
}:

let
  emacs-icns = fetchzip {
    url = "https://darrinhenein.com/downloads/emacs-icon-1.0.icns.zip";
    hash = "sha256-7hZFw0D2088AZcymGkhoes9R4x1N66X6cbOzyv6GRtY=";
    stripRoot = false;
  };

  patches.round-undecorated-frame = fetchpatch {
    url = "https://github.com/d12frosted/homebrew-emacs-plus/raw/refs/heads/master/patches/emacs-31/round-undecorated-frame.patch";
    hash = "sha256-WWLg7xUqSa656JnzyUJTfxqyYB/4MCAiiiZUjMOqjuY=";
  };
  patches.system-appearance = fetchpatch {
    url = "https://github.com/d12frosted/homebrew-emacs-plus/raw/refs/heads/master/patches/emacs-31/system-appearance.patch";
    hash = "sha256-4+2U+4+2tpuaThNJfZOjy1JPnneGcsoge9r+WpgNDko=";
  };

  my-emacs = emacs-git-pgtk.override {
    withTreeSitter = true;
    withNativeCompilation = true;
  };
  my-emacs' = my-emacs.overrideAttrs (old: {
    patches = old.patches or [] ++ builtins.attrValues patches;
    postFixup = old.postFixup or "" + ''
      cp ${emacs-icns}/emacs-icon-1.0.icns $out/Applications/Emacs.app/Contents/Resources/Emacs.icns
    '';
  });
in

my-emacs'
