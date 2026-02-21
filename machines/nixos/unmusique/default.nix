{
  config,
  inputs,
  pkgs,
  self,
  ...
}:
let
  pkgsUnstable = import inputs.nixpkgs-unstable {
    system = config.rv32ima.machine.platform;
  };
in
{
  imports = [
    (self.lib.nixosModule "nixos/impermanence")
    (self.lib.nixosModule "nixos/zfs-mirror")
    (self.lib.nixosModule "nixos/remote-builder")

    (self.lib.userModule "root")
    (self.lib.userModule "ellie")

    ./network.nix
  ];

  config = {
    rv32ima.machine.enableZfsMirror = true;
    rv32ima.machine.zfsMirrorDisks = [
      "/dev/disk/by-id/ata-MK000480GZXRA_S6M8NE0RC00250"
      "/dev/disk/by-id/ata-MK000480GZXRA_S6M8NE0T100628"
    ];
    rv32ima.machine.impermanence.extraPersistDirectories = [

      {
        path = /var/lib/grafana;
        mode = "0770";
        owner = "grafana";
        group = "grafana";
      }
      {
        path = /var/lib/postgresql;
        mode = "0770";
        owner = "postgres";
        group = "postgres";
      }
    ];
    rv32ima.machine.remote-builder.enable = true;

    services.getty.autologinUser = "root";

    boot.initrd.availableKernelModules = [
      "ahci"
      "xhci_pci"
      "megaraid_sas"
      "usbhid"
      "usb_storage"
      "sd_mod"
      "sr_mod"
      "hpsa"
    ];
    boot.initrd.kernelModules = [ ];
    boot.kernelModules = [ "kvm-intel" ];
    boot.extraModulePackages = [ ];

    networking.hostId = "b89ce780";

    services.tailscale.enable = true;
    services.tailscale.package = pkgsUnstable.tailscale;
    services.tailscale.openFirewall = true;
    services.tailscale.useRoutingFeatures = "both";
    services.tailscale.extraSetFlags = [ "--accept-routes" ];
    networking.firewall.trustedInterfaces = [ "tailscale0" ];

    services.prometheus.exporters.node.enable = true;

    services.openssh.enable = true;
    services.openssh.openFirewall = false;

    programs.fish.enable = true;
    programs.fish.useBabelfish = true;

    networking.useNetworkd = true;
    networking.firewall.allowedTCPPorts = [ ];

    services.victoriametrics.enable = true;
    services.victoriametrics.retentionPeriod = "30d";

    sops.secrets."services/tailscalesd/environment" = {
      sopsFile = ./secrets/tailscalesd.yaml;
    };

    virtualisation.oci-containers.containers."tailscalesd" = {
      image = "ghcr.io/cfunkhouser/tailscalesd:main";
      hostname = "tailscalesd";
      ports = [ "127.0.0.1:9242:9242" ];
      environmentFiles = [
        config.sops.secrets."services/tailscalesd/environment".path
      ];
    };

    services.vmagent.enable = true;
    services.vmagent.remoteWrite.url = "http://localhost:8428/api/v1/write";
    services.vmagent.prometheusConfig = {
      scrape_configs = [
        {
          job_name = "tailscale-node-exporter";
          http_sd_configs = [
            {
              url = "http://localhost:9242";
            }
          ];
          relabel_configs = [
            {
              source_labels = [ "__meta_tailscale_device_hostname" ];
              target_label = "tailscale_hostname";
            }
            {
              source_labels = [ "__meta_tailscale_device_name" ];
              target_label = "tailscale_name";
            }
            {
              source_labels = [ "__address__" ];
              regex = "(.*)";
              replacement = "$1:9100";
              target_label = "__address__";
            }
          ];
        }
        {
          job_name = "restic-exporter";
          static_configs = [
            {
              targets = [
                "http://sisterhood.tail09d5b.ts.net:9753"
              ];
            }
          ];
        }
      ];
    };

    sops.secrets."services/tsidp/environment" = {
      sopsFile = ./secrets/tsidp.yaml;
    };

    systemd.services.tsidp = {
      description = "Tailscale OIDC Identity Provider";
      wantedBy = [ "multi-user.target" ];
      serviceConfig = {
        ExecStart = "${pkgsUnstable.tailscale}/bin/tsidp --hostname=tsidp --dir=/var/lib/tailscale/tsidp --port=443";
        Environment = [ "TAILSCALE_USE_WIP_CODE=1" ];
        EnvironmentFile = [
          # config.sops.secrets."services/tsidp/environment".path
        ];
        Restart = "always";
      };
    };

    sops.secrets."services/grafana/client_secret" = {
      sopsFile = ./secrets/grafana.yaml;
      owner = config.users.users.grafana.name;
      group = config.users.users.grafana.group;
    };

    services.grafana.enable = true;
    services.grafana.settings = {
      server = {
        root_url = "https://grafana.tail09d5b.ts.net";
        domain = "grafana.tail09d5b.ts.net";
        enforce_domain = true;
        enable_gzip = true;
      };

      "auth.generic_oauth" = {
        enabled = true;
        allow_sign_up = true;
        auto_login = true;
        client_id = "1b06567debbc724522087d666774dab9";
        client_secret = "$__file{${config.sops.secrets."services/grafana/client_secret".path}}";
        scopes = "openid profile email";
        allow_assign_grafana_admin = true;
        auth_url = "https://tsidp.tail09d5b.ts.net/authorize/3445028570815881";
        token_url = "https://tsidp.tail09d5b.ts.net/token";
        api_url = "https://tsidp.tail09d5b.ts.net/userinfo";
        login_attribute_path = "email";
        role_attribute_path = "role";
      };

      database = {
        type = "postgres";
        name = "grafana";
        host = "/run/postgresql";
        user = "grafana";
      };
    };

    services.grafana.provision.datasources.settings.datasources = [
      {
        name = "Victoria Metrics";
        type = "prometheus";
        isDefault = true;
        url = "http://localhost:8428";
      }
    ];

    services.postgresql.enable = true;
    services.postgresql.ensureDatabases = [ "grafana" ];
    services.postgresql.ensureUsers = [
      {
        name = "grafana";
        ensureDBOwnership = true;
      }
    ];

    nixpkgs.hostPlatform = "x86_64-linux";
    system.stateVersion = "25.11";
    networking.hostName = "unmusique";
    networking.domain = "sea.t4t.net";

  };
}
