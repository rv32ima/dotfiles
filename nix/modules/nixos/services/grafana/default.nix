{ config, ... }: {
  config = {
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

    sops.secrets."services/grafana/client_secret" = {
      sopsFile = ./secrets.yaml;
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
        client_id = "dd4efe4bf9d92db1e95231ae158d4adc";
        client_secret = "$__file{${config.sops.secrets."services/grafana/client_secret".path}}";
        scopes = "openid profile email";
        allow_assign_grafana_admin = true;
        auth_url = "https://tsidp.tail09d5b.ts.net/authorize";
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

    rv32ima.machine.tailscale.services.grafana = {
      port = 3000;
    };

    services.postgresql.enable = true;
    services.postgresql.ensureDatabases = [ "grafana" ];
    services.postgresql.ensureUsers = [
      {
        name = "grafana";
        ensureDBOwnership = true;
      }
    ];

  };
}
