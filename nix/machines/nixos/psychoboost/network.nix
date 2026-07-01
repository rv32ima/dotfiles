{ lib, ... }:
{
  networking.useDHCP = lib.mkDefault false;
  networking.useNetworkd = true;
  networking.firewall.checkReversePath = "loose";

  systemd.network.netdevs."bond0".netdevConfig = {
    Kind = "bond";
    Name = "bond0";
    MACAddress = "0c:42:a1:71:6a:16";
  };

  systemd.network.netdevs."bond0".bondConfig = {
    Mode = "802.3ad";
    TransmitHashPolicy = "layer3+4";
    LACPTransmitRate = "fast";
  };

  systemd.network.networks."bond0-p1" = {
    matchConfig.PermanentMACAddress = "0c:42:a1:71:6a:16";
    networkConfig.Bond = "bond0";
  };

  systemd.network.networks."bond0-p2" = {
    matchConfig.PermanentMACAddress = "0c:42:a1:71:6a:17";
    networkConfig.Bond = "bond0";
  };

  systemd.network.networks."bond0" = {
    matchConfig.Name = "bond0";

    networkConfig = {
      DHCP = true;
      IPv6AcceptRA = true;
    };

    dhcpV6Config.WithoutRA = "solicit";
  };
}
