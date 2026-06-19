{ config, ... }: {
  config = {
    sops.secrets."services/tailscalesd/environment" = {
      sopsFile = ./secrets.yaml;
    };

    virtualisation.oci-containers.containers."tailscalesd" = {
      image = "ghcr.io/cfunkhouser/tailscalesd:main";
      hostname = "tailscalesd";
      ports = [ "127.0.0.1:9242:9242" ];
      environmentFiles = [
        config.sops.secrets."services/tailscalesd/environment".path
      ];
    };

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
  };
}
