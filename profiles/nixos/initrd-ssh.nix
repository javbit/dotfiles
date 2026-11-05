{ ... }:

# Unlock LUKS over SSH from the initrd (ethernet only).
# Connect with: ssh -p 2222 root@framework, then run `systemd-tty-ask-password-agent`.
# NOTE: the host key is embedded in the initrd on the unencrypted /boot, so it
# is only meant to let you verify the host, not to be secret from disk access.
{
  boot.initrd.systemd.enable = true;

  # USB ethernet dongle (Framework expansion card) + common NICs.
  boot.initrd.availableKernelModules = [ "r8152" "cdc_ncm" "cdc_ether" "ax88179_178a" ];

  boot.initrd.systemd.network = {
    enable = true;
    networks."10-wired" = {
      matchConfig.Type = "ether";
      networkConfig.DHCP = "yes";
    };
  };

  boot.initrd.network.ssh = {
    enable = true;
    port = 2222;
    hostKeys = [ "/etc/secrets/initrd/ssh_host_ecdsa_key" ];
    authorizedKeys = [
      "sk-ecdsa-sha2-nistp256@openssh.com AAAAInNrLWVjZHNhLXNoYTItbmlzdHAyNTZAb3BlbnNzaC5jb20AAAAIbmlzdHAyNTYAAABBBJamLc1rkSpNloE5bzfpcM7RpGFqUfnqMZ8aq08e08PHZt3g/F/c2/umzVFxaXUtNB2c9shy5ejBayjrSptDlyUAAAAEc3NoOg== ssh:"
    ];
  };
}
