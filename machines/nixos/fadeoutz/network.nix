{ lib, ... }:
{
  networking.useDHCP = lib.mkDefault false;
  networking.useNetworkd = true;
  services.resolved.enable = false;

  systemd.network.networks."01-ethernet" = {
    enable = true;
    matchConfig.PermanentMACAddress = "B0:26:28:C2:C7:20";

    dns = [
      "1.1.1.1"
      "1.0.0.1"
    ];

    routes = [
      {
        Gateway = "108.62.157.254";
      }
    ];

    addresses = [
      {
        Address = "108.62.157.229/27";
      }
    ];
  };
}
