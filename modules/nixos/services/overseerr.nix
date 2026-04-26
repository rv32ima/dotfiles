{ ... }:
{
  config = {
    # rv32ima.machine.impermanence.extraPersistDirectories = [
    #   {
    #     path = /var/lib/radarr/.config/Radarr;
    #     mode = "0770";
    #     owner = "radarr";
    #     group = "radarr";
    #   }
    # ];

    services.overseerr.enable = true;
    rv32ima.machine.tailscale.services.overseerr = {
      port = 5055;
    };
  };
}
