{
  config,
  pkgs,
  lib,
  ...
}:
{
  config = {
    sops.secrets."services/openbao/environment" = {
      sopsFile = ./secrets.yaml;
    };

    security.acme.acceptTerms = true;
    security.acme.certs."bao.t4t.net" = {
      email = "ellie@t4t.net";
      server = "https://ca.t4t.net/acme/acme/directory";
      listenHTTP = ":80";
      extraDomainNames = [
        "bao-cluster.tail09d5b.ts.net"
        "bao.tail09d5b.ts.net"
      ];
      reloadServices = [
        "openbao.service"
      ];
      group = "openbao";
    };

    services.openbao = {
      enable = true;
      settings = {
        ui = true;
        cluster_addr = "https://bao-cluster.tail09d5b.ts.net";
        api_addr = "https://bao.tail09d5b.ts.net";
        listener.default = {
          type = "tcp";
          address = "0.0.0.0:8200";
          cluster_address = "127.0.0.1:8201";
          tls_cert_file = "/var/lib/acme/bao.t4t.net/cert.pem";
          tls_key_file = "/var/lib/acme/bao.t4t.net/key.pem";
          tls_client_ca_file = pkgs.writeText "ca.t4t.net.crt" ''
            -----BEGIN CERTIFICATE-----
            MIIBdzCCAR6gAwIBAgIRAOt62aP/10qbOJLfV2a55YcwCgYIKoZIzj0EAwIwGjEY
            MBYGA1UEAxMPdDR0Lm5ldCBSb290IENBMB4XDTI1MTEwMzIwMTU0MFoXDTM1MTEw
            MTIwMTU0MFowGjEYMBYGA1UEAxMPdDR0Lm5ldCBSb290IENBMFkwEwYHKoZIzj0C
            AQYIKoZIzj0DAQcDQgAE5q+OxRCMJTMZHxK5Q2ktNqo5Q8c1TqHTRpRNmRQUIUTD
            IQRj7tanAJ6xFQ5HGhFQubu99PkuTN84Zi8vwuh0qqNFMEMwDgYDVR0PAQH/BAQD
            AgEGMBIGA1UdEwEB/wQIMAYBAf8CAQEwHQYDVR0OBBYEFNTCJY/o65snwb2moOfQ
            byid3HyZMAoGCCqGSM49BAMCA0cAMEQCIAtDhcwAJIMU+GwRHE7ontjyldmtCPJy
            wgj7Kqknh2j9AiACrmmlXkcbFsqEo2SdJ5r1vD7uzYBSF5ONseGRFHJwqQ==
            -----END CERTIFICATE-----
          '';
        };

        seal.awskms = {
          region = "us-west-2";
          kms_key_id = "029a91af-8083-4680-a76f-28735b60221a";
        };

        storage.raft = {
          path = "/var/lib/openbao";
          node_id = "${config.networking.hostName}";
        };
      };
    };

    systemd.services.openbao = {
      serviceConfig = {
        EnvironmentFile = config.sops.secrets."services/openbao/environment".path;
        # Create a user so that we can set ACME certificate permissions correctly T_T
        DynamicUser = lib.mkForce false;
      };
    };

    users.users."openbao" = {
      home = "/var/lib/openbao";
      group = "openbao";
      isSystemUser = true;
    };

    users.groups."openbao" = { };

    rv32ima.machine.tailscale.services.bao = {
      targetUnit = "openbao.service";
      listenTypes = [
        {
          type = "http";
          port = 80;
          targetPort = 80;
        }
        {
          type = "tcp";
          port = 8200;
          targetPort = 8200;
        }
      ];
    };

    rv32ima.machine.tailscale.services.bao-cluster = {
      targetUnit = "openbao.service";
      listenTypes = [
        {
          type = "http";
          port = 80;
          targetPort = 80;
        }
        {
          type = "tcp";
          port = 8201;
          targetPort = 8201;
        }
      ];
    };

    networking.firewall.allowedTCPPorts = [
      80
      8200
    ];

  };
}
