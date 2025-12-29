{
  config,
  inputs,
  pkgs,
  ...
}:
let
  pkgsUnstable = import inputs.nixpkgs-unstable {
    system = config.rv32ima.machine.platform;
  };
in
{
  imports = [
    ./network.nix
    ./disk-config.nix
  ];

  config = {
    rv32ima.machine.enable = true;
    rv32ima.machine.hostName = "sisterhood";
    rv32ima.machine.stateVersion = "25.05";
    rv32ima.machine.platform = "x86_64-linux";
    rv32ima.machine.users = [
      "root"
      "ellie"
    ];
    rv32ima.machine.isRemote = true;
    rv32ima.machine.impermanence.enable = true;
    rv32ima.machine.impermanence.extraPersistDirectories = [
      {
        path = /var/lib/slskd;
        mode = "0770";
        owner = "slskd";
        group = "slskd";
      }
      {
        path = /var/lib/rtorrent;
        mode = "0770";
        owner = "rtorrent";
        group = "rtorrent";
      }
      {
        path = /var/lib/rutorrent;
        mode = "0775";
        owner = "rutorrent";
        group = "rutorrent";
      }
      {
        path = /var/lib/radarr/.config/Radarr;
        mode = "0770";
        owner = "radarr";
        group = "radarr";
      }
      {
        path = /var/lib/syncthing;
        mode = "0770";
        owner = "syncthing";
        group = "syncthing";
      }
      {
        path = /var/lib/sonarr/.config/Sonarr;
        mode = "0770";
        owner = "sonarr";
        group = "sonarr";
      }
    ];
    rv32ima.machine.remote-builder.enable = true;

    services.getty.autologinUser = "root";

    boot.initrd.availableKernelModules = [
      "ahci"
      "xhci_pci"
      "megaraid_sas"
      "usbhid"
      "usb_storage"
      "sd_mod"
      "sr_mod"
    ];
    boot.initrd.kernelModules = [ ];
    boot.kernelModules = [ "kvm-intel" ];
    boot.extraModulePackages = [ ];

    # head -c4 /dev/urandom | od -A none -t x4
    networking.hostId = "a41ae525";

    services.tailscale.enable = true;
    services.tailscale.package = pkgsUnstable.tailscale;
    services.tailscale.openFirewall = true;
    services.tailscale.useRoutingFeatures = "both";
    services.tailscale.extraSetFlags = [ "--accept-routes" ];
    networking.firewall.trustedInterfaces = [ "tailscale0" ];

    services.prometheus.exporters.node.enable = true;

    services.openssh.enable = true;
    services.openssh.openFirewall = false;

    programs.fish.enable = true;
    programs.fish.useBabelfish = true;

    networking.useNetworkd = true;
    networking.firewall.allowedTCPPorts = [ ];
    networking.firewall.logRefusedConnections = false;

    services.plex.enable = true;
    services.plex.openFirewall = true;
    services.plex.dataDir = "/persist/var/lib/plex";

    sops.secrets."services/soulseek/environment" = {
      sopsFile = ./secrets/soulseek.yaml;
    };

    services.slskd.enable = true;
    services.slskd.openFirewall = true;
    services.slskd.settings = {
      shares.directories = [
        "/media/music"
      ];
      directories.downloads = "/media/downloads/slskd/complete";
      directories.incomplete = "/media/downloads/slskd/incomplete";
    };
    services.slskd.domain = "slskd.tail09d5b.ts.net";
    services.slskd.environmentFile = config.sops.secrets."services/soulseek/environment".path;

    services.rtorrent.enable = true;
    services.rtorrent.openFirewall = true;
    services.rtorrent.downloadDir = "/media/downloads/rtorrent";
    services.rtorrent.configText = ''
      system.umask.set = 0000
    '';
    services.nginx.appendHttpConfig = ''
      server {
        listen 127.0.0.1:5050;
        server_name localhost;
        location / {
            include ${pkgs.nginx}/conf/scgi_params;
            scgi_pass unix:/run/rtorrent/rpc.sock;
        }
      }
    '';

    services.rutorrent.enable = true;
    services.rutorrent.hostName = "rutorrent.tail09d5b.ts.net";
    services.rutorrent.nginx.enable = true;

    services.syncthing.enable = true;
    services.syncthing.guiAddress = "0.0.0.0:8384";
    services.syncthing.openDefaultPorts = true;
    services.syncthing.dataDir = "/media/syncthing";
    services.syncthing.databaseDir = "/var/lib/syncthing";
    services.syncthing.configDir = "/etc/syncthing";
    systemd.tmpfiles.rules = [
      "d /etc/syncthing 0644 syncthing syncthing"
    ];
    services.syncthing.systemService = true;
    services.syncthing.user = "syncthing";
    services.syncthing.group = "syncthing";
    services.syncthing.overrideDevices = true;
    services.syncthing.overrideFolders = true;
    services.syncthing.settings = {
      devices = {
        "gold-experience" = {
          id = "E6AB7XY-6JCMYME-7ZPIPEK-4G6K5IF-TL2QOL2-6VBS727-44O2T3W-GGNAWAP";
        };
      };
      folders = {
        "Music" = {
          path = "/media/music";
          devices = [ "gold-experience" ];
        };
      };
    };

    services.radarr.enable = true;
    services.sonarr.enable = true;
    services.prowlarr.enable = true;

    sops.secrets."services/restic/media/password" = {
      sopsFile = ./secrets/restic.yaml;
    };

    sops.secrets."services/restic/media/rcloneConfig" = {
      sopsFile = ./secrets/restic.yaml;
    };

    services.restic.backups."media" = {
      initialize = true;
      repository = "rclone:secret:restic/media";
      paths = [
        "/media"
      ];
      passwordFile = config.sops.secrets."services/restic/media/password".path;
      rcloneConfigFile = config.sops.secrets."services/restic/media/rcloneConfig".path;
    };
  };
}
