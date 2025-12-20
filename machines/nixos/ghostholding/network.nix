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

  systemd.network.networks."01-mgmt" = {
    enable = true;
    matchConfig.PermanentMACAddress = "ec:0d:9a:ce:e0:4a";

    addresses = [
      {
        Address = "172.20.2.214/32";
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

  # HAHAHAHAHAHAHAHAHAHA we are VERY funny here
  systemd.services."cofractal-jank" = {
    script = ''
      set -eu
      ${pkgs.nettools}/bin/arp -i uplink -s -n 169.254.169.254 e4:dc:5f:f0:03:b0
    '';
    serviceConfig = {
      Type = "oneshot";
      User = "root";
    };
    wantedBy = [ "network-online.target" ];
    after = [
      "network.target"
      "network-online.target"
    ];
  };
}
