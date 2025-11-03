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
    rv32ima.machine.hostName = "silver-chariot";
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
      "/dev/disk/by-id/scsi-364cd98f0bbce9400305770c1cebe185d"
      "/dev/disk/by-id/scsi-364cd98f0bbce9400305770c2d0c58853"
    ];
    rv32ima.machine.impermanence.extraPersistDirectories = [
      {
        path = /var/lib/cloudflared;
        mode = "0770";
        owner = "nobody";
        group = "nogroup";
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
    ];
    boot.initrd.kernelModules = [ ];
    boot.kernelModules = [ "kvm-intel" ];
    boot.extraModulePackages = [ ];

    # head -c4 /dev/urandom | od -A none -t x4
    networking.hostId = "a76f6c36";

    sops.secrets."services/tailscale/authKey" = {
      sopsFile = ./secrets/tailscale.yaml;
    };

    services.tailscale.enable = true;
    services.tailscale.package = pkgsUnstable.tailscale;
    services.tailscale.openFirewall = true;
    services.tailscale.useRoutingFeatures = "both";
    services.tailscale.authKeyFile = config.sops.secrets."services/tailscale/authKey".path;
    services.tailscale.authKeyParameters.ephemeral = false;
    services.tailscale.authKeyParameters.preauthorized = true;
    services.tailscale.extraUpFlags = [
      "--advertise-tags=tag:infra"
      "--accept-routes"
    ];
    services.tailscale.extraSetFlags = [ "--accept-routes" ];
    networking.firewall.trustedInterfaces = [ "tailscale0" ];

    services.prometheus.exporters.node.enable = true;

    services.openssh.enable = true;
    services.openssh.openFirewall = false;

    programs.fish.enable = true;
    programs.fish.useBabelfish = true;

    networking.useNetworkd = true;
    networking.firewall.allowedTCPPorts = [ ];

    sops.secrets."services/step-ca/intermediatePassword" = {
      sopsFile = ./secrets/step-ca.yaml;
      owner = config.users.users.step-ca.name;
      group = config.users.users.step-ca.group;
    };

    sops.secrets."services/step-ca/intermediateCAPrivateKey" = {
      sopsFile = ./secrets/step-ca.yaml;
      owner = config.users.users.step-ca.name;
      group = config.users.users.step-ca.group;
    };

    sops.secrets."services/step-ca/rootCAPrivateKey" = {
      sopsFile = ./secrets/step-ca.yaml;
      owner = config.users.users.step-ca.name;
      group = config.users.users.step-ca.group;
    };

    services.step-ca.enable = true;
    services.step-ca.intermediatePasswordFile =
      config.sops.secrets."services/step-ca/intermediatePassword".path;
    services.step-ca.port = 8443;
    services.step-ca.address = "127.0.0.1";
    services.step-ca.settings =
      let
        rootCA = pkgs.writeText "root_ca.crt" ''
          -----BEGIN CERTIFICATE-----
          MIIBqzCCAVKgAwIBAgIRANo92RkDVcS+H3fYj3xAPdwwCgYIKoZIzj0EAwIwNDEU
          MBIGA1UEChMLdDR0Lm5ldCBQS0kxHDAaBgNVBAMTE3Q0dC5uZXQgUEtJIFJvb3Qg
          Q0EwHhcNMjUxMTAzMDA0NjAwWhcNMzUxMTAxMDA0NjAwWjA0MRQwEgYDVQQKEwt0
          NHQubmV0IFBLSTEcMBoGA1UEAxMTdDR0Lm5ldCBQS0kgUm9vdCBDQTBZMBMGByqG
          SM49AgEGCCqGSM49AwEHA0IABCpsc7ku1iaGpo1UONzFTYL60Lb4QT3b+2oVhik4
          E6bnG+z+BfUEZs8mpi78h60dx5nnbByC74LjUsjRlRDRdlyjRTBDMA4GA1UdDwEB
          /wQEAwIBBjASBgNVHRMBAf8ECDAGAQH/AgEBMB0GA1UdDgQWBBQrLOyzATS+uMfZ
          f0rM/vGhqvwRnTAKBggqhkjOPQQDAgNHADBEAiBwYbbf1B255oWVAqsiOYGj2+tL
          tAdKKcOmOJ9vGs6OnQIgMQM164ttoS1dL2BFebWbx/yun4zlV0Uy0fJnvfFYd68=
          -----END CERTIFICATE-----
        '';
        intermediateCA = pkgs.writeText "intermediate_ca.crt" ''
          -----BEGIN CERTIFICATE-----
          MIIB1DCCAXqgAwIBAgIQWel5LO2/OvzZDp5zq4xomzAKBggqhkjOPQQDAjA0MRQw
          EgYDVQQKEwt0NHQubmV0IFBLSTEcMBoGA1UEAxMTdDR0Lm5ldCBQS0kgUm9vdCBD
          QTAeFw0yNTExMDMwMDQ2MDFaFw0zNTExMDEwMDQ2MDFaMDwxFDASBgNVBAoTC3Q0
          dC5uZXQgUEtJMSQwIgYDVQQDExt0NHQubmV0IFBLSSBJbnRlcm1lZGlhdGUgQ0Ew
          WTATBgcqhkjOPQIBBggqhkjOPQMBBwNCAAStn3h6a0BKBN1SUnOnpod6YZACGyst
          r21nfygltsyQCmbAZuorMA4frf3nXzWbpQD4h5lPhnuSJEGNQXdwxoTMo2YwZDAO
          BgNVHQ8BAf8EBAMCAQYwEgYDVR0TAQH/BAgwBgEB/wIBADAdBgNVHQ4EFgQULAdj
          cruVzF+2RWImJsKbBxx1rbwwHwYDVR0jBBgwFoAUKyzsswE0vrjH2X9KzP7xoar8
          EZ0wCgYIKoZIzj0EAwIDSAAwRQIhAOywq6Qn7jz7xSk2mjPxjAmVSvf7j4842Pgy
          hEbvSzA2AiA0iGQkqDudg9ce1Acey/ch3zr2A/y22OiGBEyJcOFDhQ==
          -----END CERTIFICATE-----
        '';
      in
      {
        address = ":8443";
        authority = {
          provisioners = [
            {
              encryptedKey = "eyJhbGciOiJQQkVTMi1IUzI1NitBMTI4S1ciLCJjdHkiOiJqd2sranNvbiIsImVuYyI6IkEyNTZHQ00iLCJwMmMiOjYwMDAwMCwicDJzIjoiYWQxWDV3bGE1NC1SV2lOWGgyUDZIUSJ9.KNMx17srvtub_Sv_jFkN9b_8Dd35OUgJpz9bIxW96mzL9Yxjnv1Cyw.4OuUOEX0-ovjMS4h.vXdeBWyRG9zcIz79SLp1jKaId0GzzgC2bVnvemly6njCAz9F7vFsDqkvoqpyeKK12ntGAnqSXmGNOO5AKgvWIuBWbHL_BoqkuHB4gX6H-_JIY1IfRquzBthfGxe6lMpNZFsKl2flgk7ZriD9IekvaFg6E2KAye3mUC7Hvjr_-kfwS558gzgQkWEqKPgvUa_HMoKxUdjwP3HW2k9KQCfdU1-4lNkJhPuz4M4nP5YH3u9Q19zcKC7LVHtU-W77XtV_MCML0duuBKVxBGZzdpeZeWWUMkFAKrKKHZMezd2sle7M7Dhmex_ahnpA9SnA3IpuuZdeUHN0U8vWpghMl1I.01_OWtgcN2syiHLS7oWx-g";
              key = {
                alg = "ES256";
                crv = "P-256";
                kid = "pPKtTVS1_YRSROMELMOlIigIR2QDP11NC36AE32eUhg";
                kty = "EC";
                use = "sig";
                x = "uMOIMakUyxTCN3Ccy57j81zJ4u4lGMdjdQ_u6olZ-L8";
                y = "DAZz4Y-gZbZWtoKml32iY7mj7VeBKI-fmm0g1Nln65M";
              };
              name = "ellie@t4t.net";
              type = "JWK";
            }
          ];
        };
        crt = "${intermediateCA}";
        db = {
          badgerFileLoadingMode = "";
          dataSource = "/var/lib/private/step-ca/db";
          type = "badgerv2";
        };
        dnsNames = [ "ca.t4t.net" ];
        federatedRoots = null;
        insecureAddress = "";
        key = config.sops.secrets."services/step-ca/intermediateCAPrivateKey".path;
        logger = {
          format = "text";
        };
        root = "${rootCA}";
        tls = {
          cipherSuites = [
            "TLS_ECDHE_ECDSA_WITH_CHACHA20_POLY1305_SHA256"
            "TLS_ECDHE_ECDSA_WITH_AES_128_GCM_SHA256"
          ];
          maxVersion = 1.3;
          minVersion = 1.2;
          renegotiation = false;
        };
      };

    sops.secrets."services/cloudflared/credentials" = {
      sopsFile = ./secrets/cloudflared.yaml;
      owner = config.users.users.nobody.name;
      group = config.users.users.nobody.group;
    };

    sops.secrets."services/cloudflared/certificate" = {
      sopsFile = ./secrets/cloudflared.yaml;
      owner = config.users.users.nobody.name;
      group = config.users.users.nobody.group;
    };
    services.cloudflared.enable = true;
    services.cloudflared.certificateFile = config.sops.secrets."services/cloudflared/certificate".path;
    services.cloudflared.tunnels."silver-chariot" = {
      ingress = {
        "ca.t4t.net" = "tcp://localhost:8443";
      };
      default = "http_status:404";
      certificateFile = config.services.cloudflared.certificateFile;
      originRequest.noTLSVerify = true;
      credentialsFile = config.sops.secrets."services/cloudflared/credentials".path;
    };
  };
}
