{ lib, ... }:
{
  networking.useDHCP = lib.mkDefault false;
  networking.useNetworkd = true;

  systemd.network.networks."01-ethernet" = {
    enable = true;
    matchConfig.PermanentMACAddress = "B4:83:51:0F:2B:52";

    dns = [
      "1.1.1.1"
      "1.0.0.1"
    ];

    routes = [
      {
        Gateway = "23.82.194.126";
      }
    ];

    addresses = [
      {
        Address = "23.82.194.70/27";
      }
    ];
  };
}
