{ ... }:
{
  config = {
    rv32ima.machine.impermanence.extraPersistDirectories = [
      {
        path = /var/lib/radarr/.config/Radarr;
        mode = "0770";
        owner = "radarr";
        group = "radarr";
      }
    ];

    services.radarr.enable = true;
    rv32ima.machine.tailscale.services.radarr = {
      port = 7878;
    };
  };
}
