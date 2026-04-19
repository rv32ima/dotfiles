{ ... }:
{
  config = {
    services.prowlarr.enable = true;
    rv32ima.machine.tailscale.services.prowlarr = {
      port = 9696;
    };
  };
}
