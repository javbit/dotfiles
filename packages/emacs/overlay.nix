final: prev:

let
  my-emacs = prev.callPackage ./my-emacs.nix {};
  my-emacs-with-pkgs = prev.callPackage ./my-emacs-with-pkgs.nix { inherit my-emacs; };
in {
  inherit my-emacs my-emacs-with-pkgs;
}
