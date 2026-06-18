{ lib, ... }:
{
  networking.useDHCP = lib.mkDefault false;
  networking.useNetworkd = true;

  systemd.network.networks."01-ethernet" = {
    enable = true;
    matchConfig.PermanentMACAddress = "D0:67:26:D5:DF:EE";

    dns = [
      "1.1.1.1"
      "1.0.0.1"
    ];

    routes = [
      {
        Gateway = "23.82.201.62";
      }
    ];

    addresses = [
      {
        Address = "23.82.201.9/26";
      }
    ];
  };
}
