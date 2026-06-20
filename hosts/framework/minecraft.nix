{ inputs, pkgs, ... }:

let
  vanillaPort = 25565;

  gtnhPort = 25566;
  gtnhVersion = "2.8.4";
  gtnhHeap = "6G";
  gtnhJre = pkgs.jdk25_headless;

  # Pinned GTNH server pack, unpacked into the store. The hash is of the zip
  # file itself (from `nix store prefetch-file`).
  gtnhZip = pkgs.fetchurl {
    url = "https://downloads.gtnewhorizons.com/ServerPacks/GT_New_Horizons_${gtnhVersion}_Server_Java_17-25.zip";
    hash = "sha256-pY13GgfdcHU13wFRkIV1U5gpbB6RODYS0tMv82mQwIw=";
  };
  gtnh-serverpack = pkgs.runCommandLocal "gtnh-serverpack-${gtnhVersion}" {
    nativeBuildInputs = [ pkgs.unzip ];
  } ''
    mkdir -p $out
    unzip -q ${gtnhZip} -d $out
  '';

  # Semi-declarative provisioning: copy the pack into the writable data dir,
  # tracking the release for mods/libraries while preserving in-place edits
  # and the world. EULA + port are enforced declaratively each start.
  gtnh-provision = pkgs.writeShellApplication {
    name = "gtnh-provision";
    runtimeInputs = [ pkgs.rsync pkgs.coreutils pkgs.gnused pkgs.gnugrep ];
    text = ''
      pack=${gtnh-serverpack}
      dest=/var/lib/gtnh
      marker="$dest/.gtnh-provisioned"

      if [ "$(cat "$marker" 2>/dev/null || true)" != "${gtnhVersion}" ]; then
        echo "Provisioning GTNH ${gtnhVersion} into $dest ..."
        # Release-tracked content (replaced on version bump):
        rsync -a --delete "$pack/mods/"      "$dest/mods/"
        rsync -a --delete "$pack/libraries/" "$dest/libraries/"
        install -m644 "$pack/lwjgl3ify-forgePatches.jar"  "$dest/"
        install -m644 "$pack"/forge-*.jar                 "$dest/"
        install -m644 "$pack/minecraft_server.1.7.10.jar" "$dest/"
        install -m644 "$pack/java9args.txt"               "$dest/"
        # Editable content: add defaults, never clobber user edits:
        rsync -a --ignore-existing "$pack/config/"          "$dest/config/"
        rsync -a --ignore-existing "$pack/serverutilities/" "$dest/serverutilities/"
        rsync -a --ignore-existing "$pack/journeymap/"      "$dest/journeymap/"
        [ -f "$dest/server.properties" ] || install -m644 "$pack/server.properties" "$dest/"
        chmod -R u+w "$dest"
        printf '%s\n' "${gtnhVersion}" > "$marker"
      fi

      # Declarative, single-source-of-truth bits:
      printf 'eula=true\n' > "$dest/eula.txt"
      if grep -q '^server-port=' "$dest/server.properties"; then
        sed -i "s/^server-port=.*/server-port=${toString gtnhPort}/" "$dest/server.properties"
      else
        printf 'server-port=%s\n' "${toString gtnhPort}" >> "$dest/server.properties"
      fi
    '';
  };
in
{
  nixpkgs.overlays = [ inputs.nix-minecraft.overlays.default ];

  services.minecraft-servers = {
    enable = true;
    eula = true;
    dataDir = "/srv/minecraft";
    # Tailscale-only: do not open public ports. The ports are exposed on the
    # tailnet interface below.
    openFirewall = false;

    servers.vanilla = {
      enable = true;
      autoStart = false;
      package = pkgs.vanillaServers.vanilla;
      jvmOpts = "-Xms2G -Xmx4G";
      serverProperties = {
        server-port = vanillaPort;
        motd = "Vanilla (framework)";
      };
    };
  };

  # GTNH runs outside nix-minecraft: its bespoke launcher and editable configs
  # don't fit the jar/symlink model. It reuses nix-minecraft's `minecraft` user.
  # No `wantedBy` => not started at boot; use `systemctl start/stop minecraft-gtnh`.
  systemd.services.minecraft-gtnh = {
    description = "GregTech: New Horizons ${gtnhVersion} Minecraft server";
    after = [ "network.target" ];
    serviceConfig = {
      User = "minecraft";
      Group = "minecraft";
      StateDirectory = "gtnh";
      WorkingDirectory = "/var/lib/gtnh";
      ExecStartPre = "${gtnh-provision}/bin/gtnh-provision";
      ExecStart = "${gtnhJre}/bin/java -Xms${gtnhHeap} -Xmx${gtnhHeap} -Dfml.readTimeout=180 @java9args.txt -jar lwjgl3ify-forgePatches.jar nogui";
      Restart = "on-failure";
      RestartSec = 10;
      # Minecraft saves the world on SIGTERM via its JVM shutdown hook; give it
      # room to finish. 143 = clean SIGTERM exit, 130 = SIGINT.
      TimeoutStopSec = 120;
      SuccessExitStatus = "0 130 143";
    };
  };

  networking.firewall.interfaces."tailscale0".allowedTCPPorts = [
    vanillaPort
    gtnhPort
  ];
}
