{ lib, ... }:
{
  networking.useDHCP = lib.mkDefault false;
  networking.useNetworkd = true;

  systemd.network.networks."01-ethernet" = {
    enable = true;
    matchConfig.PermanentMACAddress = "00:30:64:76:4c:b3";
    networkConfig.DHCP = "yes";

    dns = [
      "1.1.1.1"
      "1.0.0.1"
    ];
  };
}
