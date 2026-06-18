{ config, ... }:
{
  config = {
    rv32ima.machine.impermanence.extraPersistDirectories = [
      {
        path = /var/lib/slskd;
        mode = "0770";
        owner = "slskd";
        group = "slskd";
      }
    ];

    sops.secrets."services/soulseek/environment" = {
      sopsFile = ./secrets.yaml;
    };

    services.slskd.enable = true;
    services.slskd.openFirewall = true;
    services.slskd.settings = {
      shares.directories = [
        "/media/music"
      ];
      directories.downloads = "/media/downloads/slskd/complete";
      directories.incomplete = "/media/downloads/slskd/incomplete";
    };
    services.slskd.domain = "slskd.tail09d5b.ts.net";
    services.slskd.environmentFile = config.sops.secrets."services/soulseek/environment".path;

    rv32ima.machine.tailscale.services.slskd = {
      port = 5030;
    };
  };
}
