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

  # Pinned commit of d12frosted/homebrew-emacs-plus for reproducible patches.
  emacs-plus-rev = "0df9688bb0f6b8e05585a5e8cdc82e0b14fb1921";
  patchUrl = name: "https://github.com/d12frosted/homebrew-emacs-plus/raw/${emacs-plus-rev}/patches/emacs-31/${name}.patch";

  patches.fix-ns-x-colors = fetchpatch {
    url = patchUrl "fix-ns-x-colors";
    hash = "sha256-oe3DFgEXwp0cZJl+ufWqTonaeWSliikTRsVDNbcy4Yw=";
  };
  patches.round-undecorated-frame = fetchpatch {
    url = patchUrl "round-undecorated-frame";
    hash = "sha256-KCMEvJzN1OkwFYoMLpZghvdeoO1Ckcxk3Mo19YAf850=";
  };
  patches.system-appearance = fetchpatch {
    url = patchUrl "system-appearance";
    hash = "sha256-4+2U+4+2tpuaThNJfZOjy1JPnneGcsoge9r+WpgNDko=";
  };

  my-emacs = emacs-git-pgtk.override {
    withTreeSitter = true;
    withNativeCompilation = true;
  };
  my-emacs' = my-emacs.overrideAttrs (old: {
    patches = old.patches or [ ] ++ builtins.attrValues patches;
    # Point the app bundle at the liquid-glass icon set in Assets.car
    # (installed below).  A substitution rather than a patch so upstream
    # edits elsewhere in Info.plist.in don't break the build; --replace-fail
    # still catches it if this exact line ever changes.
    postPatch = old.postPatch or "" + ''
      substituteInPlace nextstep/templates/Info.plist.in \
        --replace-fail '<string>Emacs.icns</string>' \
                       '<string>Emacs.icns</string>
	<key>CFBundleIconName</key>
	<string>EmacsLG3</string>'
    '';
    postFixup = old.postFixup or "" + ''
      cp ${emacs-icons}/Resources/Assets.car $out/Applications/Emacs.app/Contents/Resources/
    '';
  });
in

my-emacs'
