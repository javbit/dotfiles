{ ... }:

{
  config = {
    # udev rules, plugdev group and DVB kernel module blacklist so an
    # RTL-SDR dongle is usable without root.  Users still need to be in
    # plugdev (set on the host user).
    hardware.rtl-sdr.enable = true;
  };
}
