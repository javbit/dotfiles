{ ... }:

{
  config = {
    # Niri, a scrollable-tiling Wayland compositor.  Registers a GDM
    # session alongside whatever else is enabled; the user side lives in
    # profiles/home/niri.nix.
    programs.niri.enable = true;

    services.displayManager.gdm.enable = true;

    # swaylock needs a PAM service to be able to unlock.
    security.pam.services.swaylock = { };
  };
}
