{ ... }:

{
  services.samba = {
    enable = true;
    # Tailscale-only: do not open public ports. Port 445 is exposed on the
    # tailnet interface below.
    openFirewall = false;

    # NetBIOS/winbind are only needed for Windows workgroup browsing and
    # domain membership; macOS speaks plain SMB3 on 445.
    nmbd.enable = false;
    winbindd.enable = false;

    settings = {
      global = {
        "server string" = "framework";
        "server role" = "standalone server";

        # smbd binds the wildcard address: it cannot bind tailscale0 at all
        # ("bind interfaces only" silently skips point-to-point interfaces
        # with no broadcast address, in every syntax — verified against
        # smbd -d2). Tailscale-only access is instead enforced by the
        # firewall (445 open solely on tailscale0) plus this address check:
        "hosts allow" = "100.64.0.0/10 fd7a:115c:a1e0::/48 127.0.0.1 ::1";
        "hosts deny" = "0.0.0.0/0 ::/0";

        "server min protocol" = "SMB3_00";
        "map to guest" = "never";

        # vfs_fruit: Apple SMB extensions (AAPL) so macOS clients get proper
        # metadata/xattr handling instead of littering ._AppleDouble files.
        "vfs objects" = "catia fruit streams_xattr";
        "fruit:aapl" = "yes";
        "fruit:metadata" = "stream";
        "fruit:model" = "MacSamba";
        "fruit:posix_rename" = "yes";
        "fruit:veto_appledouble" = "no";
        "fruit:nfs_aces" = "no";
        "fruit:wipe_intentionally_left_blank_rfork" = "yes";
        "fruit:delete_empty_adfiles" = "yes";
      };

      storage = {
        path = "/srv/storage";
        browseable = "yes";
        "read only" = "no";
        "valid users" = "jav";
        "create mask" = "0644";
        "directory mask" = "0755";
      };

      # Transmission downloads from the seedbox container (see seedbox.nix:
      # dir is setgid 70:torrents and transmission writes group-writable, so
      # jav gets access via the torrents group; force group keeps jav-created
      # files consistent with that).
      torrents = {
        path = "/srv/torrents";
        browseable = "yes";
        "read only" = "no";
        "valid users" = "jav";
        "force group" = "torrents";
        "create mask" = "0664";
        "directory mask" = "2775";
      };
    };
  };

  systemd.tmpfiles.rules = [
    "d /srv/storage 0750 jav users -"
  ];

  # Advertise the share to the tailnet via unicast DNS-SD ("wide-area
  # Bonjour"): mDNS multicast cannot traverse Tailscale, but macOS also
  # browses for services with plain DNS queries against its search domains
  # (the b./lb._dns-sd._udp meta-records below opt the domain into that).
  # dnsmasq serves the home.arpa zone on the tailnet interface only.
  #
  # Requires two one-time settings in the Tailscale admin console (DNS tab):
  #   1. Nameservers -> add custom nameserver 100.85.24.71, restricted to
  #      the domain home.arpa (split DNS).
  #   2. Search domains -> add home.arpa.
  #   3. On each Mac: sudo networksetup -setsearchdomains Wi-Fi home.arpa
  #      (the primary network service, not the Tailscale one — networksetup
  #      DNS settings on a non-primary service are inert). Tailscale's own
  #      search domains arrive as a supplemental resolver, which resolves
  #      names fine but is ignored by mDNSResponder's browse-domain
  #      enumeration, so without this Finder never issues the b./lb. queries.
  services.dnsmasq = {
    enable = true;
    # Serve the tailnet only; don't touch the framework's own resolv.conf.
    resolveLocalQueries = false;
    settings = {
      interface = "tailscale0";
      bind-dynamic = true; # tailscale0 may come up after dnsmasq
      except-interface = "lo";
      no-resolv = true; # authoritative-only: no upstream forwarding
      no-hosts = true;
      local = "/home.arpa/";
      host-record = "framework.home.arpa,100.85.24.71,fd7a:115c:a1e0::c73b:1848";
      ptr-record = [
        # Browse-domain enumeration: tells clients home.arpa is browsable.
        "b._dns-sd._udp.home.arpa,home.arpa"
        "lb._dns-sd._udp.home.arpa,home.arpa"
        "_services._dns-sd._udp.home.arpa,_smb._tcp.home.arpa"
        # The service instance itself.
        "_smb._tcp.home.arpa,framework._smb._tcp.home.arpa"
      ];
      srv-host = "framework._smb._tcp.home.arpa,framework.home.arpa,445";
      txt-record = [
        # DNS-SD requires a TXT record per instance, even an empty one.
        "framework._smb._tcp.home.arpa"
        "framework._device-info._tcp.home.arpa,model=MacSamba"
      ];
    };
  };

  networking.firewall.interfaces."tailscale0" = {
    allowedTCPPorts = [
      445 # smb
      53 # dns-sd
    ];
    allowedUDPPorts = [
      53 # dns-sd
    ];
  };
}
