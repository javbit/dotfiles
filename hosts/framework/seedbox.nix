{ pkgs, lib, ... }:

let
  hostAddress = "10.100.0.1";
  localAddress = "10.100.0.2";
  rpcPort = 9091;
  # nixpkgs ids.nix: transmission uid/gid. Containers share host uids (no
  # userns), so files written in the container land on the host as 70:70.
  transmissionId = 70;
in
{
  ############################
  # Host side
  ############################

  # Masquerade + forwarding sysctls for the container veth. No
  # externalInterface: the nftables backend masquerades by iifname, which
  # works for any uplink (wifi or dock).
  networking.nat = {
    enable = true;
    internalInterfaces = [ "ve-seedbox" ];
  };

  # Defense in depth: even with the container's own ruleset gone, it can
  # reach only the raw internet (which tailscaled needs), never the LAN,
  # link-local, or the tailnet CGNAT range.
  # filterForward is host-global (forward chain becomes policy drop with
  # established/related auto-accepted); any future Docker/subnet-router use
  # on this host needs its own accept rules here.
  networking.firewall.filterForward = true;
  networking.firewall.extraForwardRules = ''
    iifname "ve-seedbox" ip daddr { 10.0.0.0/8, 172.16.0.0/12, 192.168.0.0/16, 169.254.0.0/16, 100.64.0.0/10, 224.0.0.0/4 } counter drop comment "seedbox container: no private/tailnet egress"
    iifname "ve-seedbox" accept comment "seedbox container: internet egress (tailscaled WG/DERP only in practice)"
  '';

  # Keep NetworkManager's hands off container veths.
  networking.networkmanager.unmanaged = [ "interface-name:ve-*" ];

  # The host itself may be on a Tailscale exit node (toggled from the
  # desktop). tailscaled then puts `default dev tailscale0` in its policy
  # table 52, which `ip rule 5270` consults for every *unmarked* packet
  # before main. Without this table that breaks the container two ways
  # (2026-09-11): the strict reverse-path filter drops its packets (the
  # fib lookup for 10.100.0.2 now answers tailscale0, not ve-seedbox), and
  # replies to 10.100.0.2 are routed into the tunnel instead of down the
  # veth. Stamping the container's flows with tailscaled's own bypass mark
  # (0x80000/0xff0000) sends them through `ip rule 5210: fwmark 0x80000
  # lookup main` in both directions, so the container always egresses via
  # the raw uplink, which is what the forward rules above assume. The
  # conntrack mark carries the decision to reply packets; it is restored
  # before the rpfilter chain (mangle + 10) evaluates them.
  networking.nftables.tables.seedbox-egress = {
    family = "inet";
    content = ''
      chain prerouting {
        type filter hook prerouting priority mangle - 1; policy accept;
        iifname "ve-seedbox" meta mark set meta mark & 0xff00ffff | 0x00080000 ct mark set meta mark comment "seedbox: bypass host tailscale policy routing"
        iifname != "ve-seedbox" ct original ip saddr ${localAddress} ct mark & 0x00ff0000 == 0x00080000 meta mark set ct mark comment "seedbox: restore bypass mark on replies"
      }
    '';
  };

  # Named group matching the container's transmission gid so jav can be a
  # member; setgid dir keeps everything group-owned.
  users.groups.torrents.gid = transmissionId;
  users.users.jav.extraGroups = [ "torrents" ];
  systemd.tmpfiles.rules = [
    "d /srv/torrents 2775 ${toString transmissionId} torrents -"
    # transmission's sandbox bind-mounts the incomplete dir at unit start,
    # so it must exist before the service can even spawn.
    "d /srv/torrents/.incomplete 2775 ${toString transmissionId} torrents -"
  ];

  ############################
  # Container (name <= 11 chars: veth name limit)
  ############################
  containers.seedbox = {
    autoStart = true;
    privateNetwork = true;
    inherit hostAddress localAddress;
    enableTun = true; # /dev/net/tun + CAP_NET_ADMIN for tailscaled
    bindMounts."/downloads" = {
      hostPath = "/srv/torrents";
      isReadOnly = false;
    };

    config = { pkgs, lib, ... }: {
      system.stateVersion = "26.05";

      # Host copies its resolv.conf in at every container start; let
      # resolved own it instead so tailscaled can program MagicDNS
      # (100.100.100.100). No working resolver is needed pre-auth:
      # tailscaled's own lookups are bypass-marked and it falls back to
      # bootstrap DNS-over-HTTPS against DERP IPs.
      networking.useHostResolvConf = lib.mkForce false;
      services.resolved.enable = true;
      # ...but the resolver must fail *fast* pre-auth. resolved's compiled-in
      # fallback servers (1.1.1.1, 8.8.8.8) are unmarked traffic that the
      # kill switch silently drops, so each lookup hung for the full timeout
      # and tailscaled's 10 s register deadline expired before it ever fell
      # back to bootstrap DNS (2026-09-11 post-reboot outage; earlier boots
      # only won the race because the first lookup ran before the default
      # route existed and failed instantly). With no fallback, resolved
      # returns SERVFAIL immediately and tailscaled bootstraps. Once logged
      # in, tailscaled installs the exit node's resolvers via the tunnel.
      services.resolved.settings.Resolve.FallbackDNS = [ ];

      services.tailscale = {
        enable = true;
        useRoutingFeatures = "client"; # reverse-path filter -> loose
        extraSetFlags = [
          "--exit-node=us-chi-wg-301.mullvad.ts.net"
          "--exit-node-allow-lan-access=false"
        ];
      };

      # Kill switch: nothing leaves except loopback, the tunnel, and
      # tailscaled's own bypass-marked sockets (control/DERP/STUN/
      # WireGuard; tailscale util/linuxfw mark 0x80000/0xff0000).
      networking.nftables.enable = true;
      networking.nftables.tables.killswitch = {
        family = "inet";
        content = ''
          chain output {
            type filter hook output priority filter; policy drop;
            oifname "lo" accept
            oifname "tailscale0" accept
            meta mark and 0x00ff0000 == 0x00080000 accept comment "tailscaled bypass-marked sockets"
            counter comment "killswitch drops"
          }
        '';
      };

      # tailscaled-set (applies extraSetFlags) races the netmap at boot:
      # until tailscaled has logged in and learned the peers, setting the
      # exit node fails. Retry until it lands. Harmless after the first
      # success (the pref persists in tailscaled state), but keeps a fresh
      # boot from needing a manual kick.
      systemd.services.tailscaled-set = {
        serviceConfig = {
          Restart = "on-failure";
          RestartSec = "5s";
        };
        unitConfig.StartLimitIntervalSec = 0;
      };

      # Publish the web UI as https://seedbox.nilgiri-hue.ts.net: tailscaled
      # terminates TLS (auto-provisioned LE cert) and proxies to the RPC
      # port. Serve traffic is handled inside tailscaled's netstack, so no
      # tailscale0 firewall port is needed, and the killswitch doesn't
      # apply (replies leave via the tun writer, not the output hook).
      # `serve --bg` persists in tailscaled state; this just (re)applies
      # it. Same boot race as tailscaled-set: serve needs the netmap
      # (HTTPS cert capability), so retry until it lands.
      systemd.services.tailscale-serve = {
        wantedBy = [ "multi-user.target" ];
        requires = [ "tailscaled.service" ];
        after = [ "tailscaled.service" ];
        serviceConfig = {
          Type = "oneshot";
          ExecStart = "${lib.meta.getExe pkgs.tailscale} serve --bg http://127.0.0.1:${toString rpcPort}";
          Restart = "on-failure";
          RestartSec = "5s";
        };
        unitConfig.StartLimitIntervalSec = 0;
      };

      # Web UI reachable only over the container's own tailnet address.
      networking.firewall.interfaces."tailscale0".allowedTCPPorts = [ rpcPort ];

      services.transmission = {
        enable = true;
        package = pkgs.transmission_4;
        openRPCPort = false; # tailscale0-only, handled above
        settings = {
          download-dir = "/downloads";
          incomplete-dir = "/downloads/.incomplete";
          umask = 2; # group-writable files for the samba share
          rpc-bind-address = "0.0.0.0"; # reachability enforced by firewall
          rpc-port = rpcPort;
          rpc-whitelist-enabled = true;
          rpc-whitelist = "127.0.0.1,100.*"; # tailnet IPv4 range
          rpc-host-whitelist-enabled = false; # allow http://seedbox:9091
          # Mullvad exit nodes have no inbound port forwarding: we are a
          # connect-only peer; UPnP would be noise.
          port-forwarding-enabled = false;
          utp-enabled = true;
        };
      };

      # Fail closed: transmission may not run without the kill switch
      # loaded. Ordering after tailscaled just reduces startup churn.
      systemd.services.transmission = {
        requires = [ "nftables.service" ];
        after = [ "nftables.service" "tailscaled.service" ];
        # The module's RootDirectory chroot cannot be assembled inside an
        # nspawn container (systemd fails propagating /run/host/
        # .os-release-stage into it). The nspawn container is already the
        # sandbox; the unit's other hardening (user, Protect*) remains.
        serviceConfig = {
          RootDirectory = lib.mkForce "";
          RootDirectoryStartOnly = lib.mkForce false;
          BindPaths = lib.mkForce [ ];
          BindReadOnlyPaths = lib.mkForce [ ];
          # The chroot's BindPaths used to make the download dir writable
          # under ProtectSystem=strict; provide that directly instead.
          ReadWritePaths = [ "/downloads" ];
        };
      };
    };
  };
}
