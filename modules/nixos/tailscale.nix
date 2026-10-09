{ lib, options, ... }:

{
  config = {
    services.tailscale = {
      enable = true;
      openFirewall = true;
      extraSetFlags = [ "--ssh" ];
    };
  }
  // lib.optionalAttrs (options.environment ? persistence) {
    environment.persistence."/persist".directories = [ "/var/lib/tailscale" ];
  };
}
