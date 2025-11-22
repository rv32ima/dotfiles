{ lib, ... }:
{
  networking.useDHCP = lib.mkDefault false;
  networking.useNetworkd = true;
  services.resolved.enable = true;
  services.resolved.fallbackDns = [
    "1.1.1.1"
    "1.0.0.1"
  ];

  systemd.network.networks."01-mgmt" = {
    enable = true;
    matchConfig.PermanentMACAddress = "ec:0d:9a:ce:e0:4a";

    dns = [
      "1.1.1.1"
      "1.0.0.1"
    ];

    routes = [
      {
        Gateway = "172.20.2.1";
      }
    ];

    addresses = [
      {
        Address = "172.20.2.214/24";
      }
    ];
  };

  systemd.network.networks."02-mgmt-too" = {
    enable = true;
    matchConfig.PermanentMACAddress = "ec:0d:9a:ce:e0:4b";
    dns = [
      "1.1.1.1"
      "1.0.0.1"
    ];
    DHCP = "yes";
  };

  systemd.network.netdevs."uplink".netdevConfig = {
    Kind = "bond";
    Name = "uplink";
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
    addresses = [
      {
        Address = "23.190.72.1/24";
      }
    ];
  };
}
