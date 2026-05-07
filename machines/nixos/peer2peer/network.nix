{ lib, ... }:
{
  networking.useDHCP = lib.mkDefault false;
  networking.useNetworkd = true;
  networking.firewall.checkReversePath = "loose";

  systemd.network.networks."01-vpro-oob-ethernet" = {
    enable = true;
    matchConfig.PermanentMACAddress = "38:05:25:38:07:AE";
    DHCP = "yes";
  };

  systemd.network.netdevs."bond0".netdevConfig = {
    Kind = "bond";
    Name = "bond0";
    MACAddress = "38:05:25:37:2b:d0";
  };

  systemd.network.netdevs."bond0".bondConfig = {
    Mode = "802.3ad";
    TransmitHashPolicy = "layer3+4";
    LACPTransmitRate = "fast";
  };

  systemd.network.networks."bond0-eno1np0" = {
    matchConfig.Name = "eno1np0";
    networkConfig.Bond = "bond0";
  };

  systemd.network.networks."bond0-eno2np1" = {
    matchConfig.Name = "eno2np1";
    networkConfig.Bond = "bond0";
  };

  systemd.network.networks."bond0" = {
    matchConfig.Name = "bond0";

    routes = [
      {
        Destination = "23.190.72.0/32";
      }
      {
        Gateway = "23.190.72.0";
      }
      {
        Destination = "2620:C2:2000::1/64";
      }
      {
        Gateway = "2620:C2:2000::1";
      }
    ];

    addresses = [
      {
        Address = "23.190.72.1/32";
      }
      {
        Address = "2620:C2:2000::2/64";
      }
    ];
  };
}
