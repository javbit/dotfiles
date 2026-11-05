{ ... }:

# Framework doubles as a server (GTNH, seedbox): never suspend or hibernate.
{
  systemd.targets = {
    sleep.enable = false;
    suspend.enable = false;
    hibernate.enable = false;
    hybrid-sleep.enable = false;
  };
}
