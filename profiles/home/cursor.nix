{ pkgs, ... }:

{
  config = {
    # One pointer theme and size for every toolkit.  GTK settings.ini and
    # the GNOME dconf keys cover Firefox/Emacs/GNOME; XCURSOR_* covers the
    # rest.  Niri is pointed at the same theme in profiles/home/niri.nix.
    home.pointerCursor = {
      package = pkgs.adwaita-icon-theme;
      name = "Adwaita";
      size = 24;
      gtk.enable = true;
      x11.enable = true;
    };
    gtk.enable = true;
  };
}
