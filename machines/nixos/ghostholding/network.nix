{ lib, pkgs, ... }:
{
  networking.useDHCP = lib.mkDefault false;
  networking.useNetworkd = true;
  services.resolved.enable = true;
  services.resolved.fallbackDns = [
    "1.1.1.1"
    "1.0.0.1"
    "2606:4700:4700::1111"
    "2606:4700:4700::1001"
  ];
  networking.firewall.logRefusedConnections = false;
  networking.firewall.logRefusedPackets = false;
  networking.firewall.logRefusedUnicastsOnly = false;
  systemd.network.wait-online.enable = false;

  systemd.network.networks."01-mgmt" = {
    enable = true;
    matchConfig.PermanentMACAddress = "ec:0d:9a:ce:e0:4a";

    addresses = [
      {
        Address = "172.20.2.214/24";
      }
    ];
  };

  systemd.network.networks."02-mgmt-too" = {
    enable = true;
    matchConfig.PermanentMACAddress = "ec:0d:9a:ce:e0:4b";
    DHCP = "yes";
  };

  systemd.network.netdevs."uplink".netdevConfig = {
    Kind = "bond";
    Name = "uplink";
    MACAddress = "ec:0d:9a:f9:e4:fd";
  };

  systemd.network.netdevs."uplink".bondConfig = {
    Mode = "802.3ad";
    TransmitHashPolicy = "layer3+4";
    LACPTransmitRate = "fast";
  };

  systemd.network.networks."uplink-swp1" = {
    matchConfig.Name = "swp1";
    networkConfig.Bond = "uplink";
  };

  systemd.network.networks."uplink-swp2" = {
    matchConfig.Name = "swp2";
    networkConfig.Bond = "uplink";
  };

  systemd.network.networks."uplink" = {
    matchConfig.Name = "uplink";

    routes = [
      {
        # don't ask why we need this, we just do
        Destination = "169.254.169.254/32";
      }
      {
        Gateway = "169.254.169.254";
      }
      {
        Gateway = "2606:7940:32:3c::1";
      }
    ];

    addresses = [
      {
        Address = "199.255.18.181/32";
      }
      {
        Address = "2606:7940:32:3c::11/120";
      }
    ];
  };

  systemd.network.networks."loopback" = {
    matchConfig.Name = "lo";
    addresses = [
      {
        Address = "23.190.72.0/24";
      }
      {
        Address = "2620:C2:2000::0/48";
      }
    ];
  };

  systemd.network.netdevs."bond0".netdevConfig = {
    Kind = "bond";
    Name = "uplink";
    MACAddress = "ec:0d:9a:f9:e4:ff";
  };

  systemd.network.netdevs."bond0".bondConfig = {
    Mode = "802.3ad";
    TransmitHashPolicy = "layer3+4";
    LACPTransmitRate = "fast";
  };

  systemd.network.networks."bond0-swp3" = {
    matchConfig.Name = "swp3";
    networkConfig.Bond = "bond0";
  };

  systemd.network.networks."bond0-swp4" = {
    matchConfig.Name = "swp4";
    networkConfig.Bond = "bond0";
  };

  # HAHAHAHAHAHAHAHAHAHA we are VERY funny here
  systemd.timers."cofractal-jank" = {
    wantedBy = [ "timers.target" ];
    timerConfig = {
      OnBootSec = "1m";
      OnUnitActiveSec = "1m";
      Unit = "cofractal-jank.service";
    };
  };

  systemd.services."fix-devlink-ratelimit" = {
    script = ''
      set -eu
      ${pkgs.iproute2}/bin/devlink trap policer set pci/0000:03:00.0 policer 14 rate 4194304 burst 4194304
    '';
    serviceConfig = {
      Type = "oneshot";
      User = "root";
    };
    after = [
      "network.target"
      "network-online.target"
    ];
  };

  systemd.services."cofractal-jank" = {
    script = ''
      set -eu
      ${pkgs.nettools}/bin/arp -i uplink -s -n 169.254.169.254 e4:dc:5f:f0:03:b0
    '';
    serviceConfig = {
      Type = "oneshot";
      User = "root";
    };
    after = [
      "network.target"
      "network-online.target"
    ];
  };
}
