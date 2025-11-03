{
  config,
  inputs,
  pkgs,
  lib,
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
    networking.firewall.allowedTCPPorts = [
      80
      443
    ];

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
    services.step-ca.port = 443;
    services.step-ca.address = "0.0.0.0";
    services.step-ca.settings =
      let
        rootCA = pkgs.writeText "root_ca.crt" ''
          -----BEGIN CERTIFICATE-----
          MIIBqzCCAVGgAwIBAgIQBImOd0v6mpOQ4bxjVQ7yxzAKBggqhkjOPQQDAjA0MRQw
          EgYDVQQKEwt0NHQubmV0IFBLSTEcMBoGA1UEAxMTdDR0Lm5ldCBQS0kgUm9vdCBD
          QTAeFw0yNTExMDMwMzM5MDFaFw0zNTExMDEwMzM5MDFaMDQxFDASBgNVBAoTC3Q0
          dC5uZXQgUEtJMRwwGgYDVQQDExN0NHQubmV0IFBLSSBSb290IENBMFkwEwYHKoZI
          zj0CAQYIKoZIzj0DAQcDQgAE/hN6RvLICvSjmrXolzly1tjzD8R0I/8q25mM7b7m
          JRorJlg78rFatKZtxaqzI0DvdCHC61VYGG8OGZflUOJKKKNFMEMwDgYDVR0PAQH/
          BAQDAgEGMBIGA1UdEwEB/wQIMAYBAf8CAQEwHQYDVR0OBBYEFH6PXcYvOoJtVLWf
          h5tvJ8EB8tQeMAoGCCqGSM49BAMCA0gAMEUCIQDfEPg6k2fvNK3cyUMET32VRnaG
          kHmeor1m/j/CGIIMeQIgVvl0HlPTtO0rSHUlhfjmaFNMieOJRvzczqEkWI/wxTM=
          -----END CERTIFICATE-----
        '';
        intermediateCA = pkgs.writeText "intermediate_ca.crt" ''
          -----BEGIN CERTIFICATE-----
          MIIB1jCCAXugAwIBAgIRAP93anDr7zr67yVmkhWYE0cwCgYIKoZIzj0EAwIwNDEU
          MBIGA1UEChMLdDR0Lm5ldCBQS0kxHDAaBgNVBAMTE3Q0dC5uZXQgUEtJIFJvb3Qg
          Q0EwHhcNMjUxMTAzMDMzOTAyWhcNMzUxMTAxMDMzOTAyWjA8MRQwEgYDVQQKEwt0
          NHQubmV0IFBLSTEkMCIGA1UEAxMbdDR0Lm5ldCBQS0kgSW50ZXJtZWRpYXRlIENB
          MFkwEwYHKoZIzj0CAQYIKoZIzj0DAQcDQgAEBI/JwUNoageIIzK/waPkFjU8EaMH
          /A5F8Sd/U89UDvCDWNa5IroslHaQG3v+To+aThME0uUdVKoGJAEFi1oF4qNmMGQw
          DgYDVR0PAQH/BAQDAgEGMBIGA1UdEwEB/wQIMAYBAf8CAQAwHQYDVR0OBBYEFLc4
          CaeCbSOX/L9zhuVSA9zgIpjCMB8GA1UdIwQYMBaAFH6PXcYvOoJtVLWfh5tvJ8EB
          8tQeMAoGCCqGSM49BAMCA0kAMEYCIQDTR2YLGdF+mpxSamAJUsukTJ9X5gbZA7ED
          yjRY8k6KUgIhAPNiMLBTEeRm127ioh5I/Jg4dICVPj9GVg9rMmXgozAJ
          -----END CERTIFICATE-----
        '';
        x509Template = pkgs.writeText "x509.tpl" ''
          {
              "subject": {{ toJson .Subject }},
              "sans": {{ toJson .SANs }},
          {{- if typeIs "*rsa.PublicKey" .Insecure.CR.PublicKey }}
              "keyUsage": ["keyEncipherment", "digitalSignature"],
          {{- else }}
              "keyUsage": ["digitalSignature"],
          {{- end }}
              "extKeyUsage": ["serverAuth", "clientAuth"]
          }
        '';
        sshTemplate = pkgs.writeText "ssh.tpl" ''
          {
            "type": {{ toJson .Type }},
            "keyId": {{ toJson .KeyID }},
            "principals": {{ toJson .Principals }},
            "extensions": {{ toJson .Extensions }},
            "criticalOptions": {{ toJson .CriticalOptions }}
          }
        '';
      in
      {
        address = ":443";
        authority = {
          provisioners = [
            {
              encryptedKey = "eyJhbGciOiJQQkVTMi1IUzI1NitBMTI4S1ciLCJjdHkiOiJqd2sranNvbiIsImVuYyI6IkEyNTZHQ00iLCJwMmMiOjYwMDAwMCwicDJzIjoid3FmT2w4Q3hldjhZeXhKQkJzdTVCdyJ9.kUyoE8KhDYII89gxRt4jHNhVNTd3ghXrKO1brT2a3zeR6VFSFgOPDA.RYlJM1hW00E4puL0.JvpEODq_yKWeHZmkv1f4pdkKsXKslnf-Z6F4mG3u4uGKqcwhUvqpLKZ0UWiMT-fHl4RekRi4XA7F_67jPqwyuvwamzRhzyfwgqLorEBs9mPZRD0AizF2RURol-kOzJHMxF6vKNWHkFuF3TKi56IvgoapQWB-AMD4hHheDWYoAL0BifR1GVGiIkBdeH7LKLve8sWk2HiOE41kX-y19zMZgmDH499JgOzV0q16-ImBXG7hSivQz18mQOQ2kkGX88DiPXwa_eg_tqmmI0tPP9oFWlRgP8D4f7aelPn0fcdy2vhm4Ik43TgRO2-U40Z3Xyq5RLOfJBiYoKiB-ztCOMU.eKW5Lv9M6FK7txhhsx22uw";
              key = {
                alg = "ES256";
                crv = "P-256";
                kid = "c83DXf8QpGr9dPE4tUWEWzIoydCTzWFqmsuZ2BTw4eE";
                kty = "EC";
                use = "sig";
                x = "l2YMYC2LVDRkOpHlCblby7-1ZHPutunJ_WW4HlAtR80";
                y = "QuAqRVFR32V28Zjw9TjopM2Ifh-jJ6sz94F0s1VeqSk";
              };
              name = "ellie@t4t.net";
              type = "JWK";
              claims = {
                enableSSHCA = true;
              };
            }
            {
              type = "ACME";
              name = "acme";
              forceCN = true;
              claims = {
                maxTLSCertDuration = "87600h";
                defaultTLSCertDuration = "87600h";
              };
              termsOfService = "";
              website = "";
              caaIdentities = [ ];
              challenges = [
                "http-01"
                "dns-01"
                "tls-alpn-01"
              ];
            }
            {
              type = "SSHPOP";
              name = "sshpop";
              claims = {
                enableSSHCA = true;
              };
              options = {
                ssh = {
                  templateFile = "${sshTemplate}";
                };
              };
            }
            {
              type = "X5C";
              name = "x5c";
              roots =
                let
                  roots = [
                    (builtins.readFile "${rootCA}")
                  ];
                  rootsStr = lib.strings.concatStrings roots;
                in
                (pkgs.callPackage "${inputs.self}/modules/shared/base64.nix" { }).toBase64 rootsStr;
              claims = {
                maxTLSCertDuration = "8h";
                defaultTLSCertDuration = "2h";
                disableRenewal = true;
                enableSSHCA = true;
              };
              options = {
                x509 = {
                  templateFile = "${x509Template}";
                };
                ssh = {
                  templateFile = "${sshTemplate}";
                };
              };
            }
          ];

          policy = {
            x509 = {
              allow = {
                dns = [ "*.sea.t4t.net" ];
              };
              allowWildcardNames = true;
            };
          };
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
  };
}
