{
  config,
  inputs,
  pkgs,
  ...
}:
let
  pkgsUnstable = import inputs.nixpkgs-unstable {
    system = config.rv32ima.machine.platform;
  };
in
{
  imports = [
    ./network.nix
  ];

  config = {
    rv32ima.machine.enable = true;
    rv32ima.machine.hostName = "unmusique";
    rv32ima.machine.stateVersion = "25.05";
    rv32ima.machine.platform = "x86_64-linux";
    rv32ima.machine.users = [
      "root"
      "ellie"
    ];
    rv32ima.machine.isRemote = true;
    rv32ima.machine.impermanence.enable = true;
    rv32ima.machine.enableZfsMirror = true;
    rv32ima.machine.zfsMirrorDisks = [
      "/dev/disk/by-id/ata-MK000480GZXRA_S6M8NE0RC00250"
      "/dev/disk/by-id/ata-MK000480GZXRA_S6M8NE0T100628"
    ];
    rv32ima.machine.impermanence.extraPersistDirectories = [
      {
        path = /var/lib/private;
        mode = "0700";
        owner = "root";
        group = "root";
      }
    ];

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
    services.vmagent.remoteWrite.url = "http://localhost:8428";
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
      ];
    };

    systemd.services.tsidp = {
      description = "Tailscale OIDC Identity Provider";
      wantedBy = [ "multi-user.target" ];
      requires = [ "tailscaled.service" ];

      serviceConfig = {
        ExecStartPre = pkgs.writeShellScript "wait-for-tailscale" ''
          while ! ${pkgsUnstable.tailscale}/bin/tailscale status &>/dev/null; do
            echo "Waiting for tailscale to be ready..."
            sleep 1
          done
        '';
        ExecStart = "${pkgsUnstable.tailscale}/bin/tsidp --use-local-tailscaled=true --dir=/var/lib/tailscale/tsidp --port=443";
        Environment = [ "TAILSCALE_USE_WIP_CODE=1" ];
        Restart = "always";
      };
    };

    services.grafana.enable = true;
    services.grafana.settings = {
      server = {
        root_url = "https://grafana.tail09d5b.ts.net";
      };

      auth.generic_oauth = {
        enabled = true;
        allow_sign_up = true;
        auto_login = true;
        client_id = "unused";
        client_secret = "unused";
        scopes = "openid profile email";
        allow_assign_grafana_admin = true;
      };
    };

    # services.grafana.provision.datasources = {

    # }
  };
}
