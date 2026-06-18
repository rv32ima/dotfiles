{ inputs, config, ... }:
{
  imports = [
    inputs.copyparty.nixosModules.default
  ];

  config = {
    rv32ima.machine.impermanence.extraPersistDirectories = [
      {
        path = /var/lib/copyparty;
        mode = "0700";
        owner = "copyparty";
        group = "copyparty";
      }
    ];
    nixpkgs.overlays = [
      inputs.copyparty.overlays.default
    ];

    services.copyparty.enable = true;
    services.copyparty.settings = {
      e2dsa = true;
      e2ts = true;
      ansi = true;

      rproxy = 1;
      idp-h-usr = "Tailscale-User-Login";
      xff-hdr = "x-forwarded-for";
      xf-host = "copyparty.tail09d5b.ts.net";
    };

    services.copyparty.volumes = {
      "/music" = {
        path = "/media/music";
        access = {
          r = "*";
          rwmd = [ "me@ellie.fm" ];
        };
      };
      "/dropbox" = {
        path = "/media/downloads/copyparty";
        access = {
          wG = "*";
          rwmd = [ "me@ellie.fm" ];
        };
        flags = {
          e2d = true;
          d2t = true;
          fk = 4;
          chmod_f = "755";
          chmod_d = "755";
        };
      };
    };

    rv32ima.machine.tailscale.services.copyparty = {
      port = 3923;
    };
  };
}
