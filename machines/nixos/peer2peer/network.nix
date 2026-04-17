{ lib, ... }:
{
  networking.useDHCP = lib.mkDefault false;
  networking.useNetworkd = true;

  systemd.network.networks."01-vpro-oob-ethernet" = {
    enable = true;
    matchConfig.PermanentMACAddress = "38:05:25:38:07:AE";
    DHCP = "yes";
  };
}
