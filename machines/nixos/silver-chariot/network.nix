{ lib, ... }:
{
  networking.useDHCP = lib.mkDefault false;
  networking.useNetworkd = true;

  systemd.network.networks."01-ethernet" = {
    enable = true;
    matchConfig.PermanentMACAddress = "B0:26:28:C2:E4:94";

    dns = [
      "1.1.1.1"
      "1.0.0.1"
    ];

    routes = [
      {
        Gateway = "108.62.194.190";
      }
    ];

    addresses = [
      {
        Address = "108.62.194.162/27";
      }
    ];
  };
}
