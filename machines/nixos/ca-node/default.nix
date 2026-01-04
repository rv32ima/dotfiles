{
  pkgs,
  inputs,
  config,
  lib,
  ...
}:
let
  settingsFormat = (pkgs.formats.json { });
  configFile = settingsFormat.generate "ca.json" (
    config.services.step-ca.settings
    // {
      address = config.services.step-ca.address + ":" + toString config.services.step-ca.port;
    }
  );
in
{
  imports = [
    "${inputs.nixpkgs}/nixos/maintainers/scripts/ec2/amazon-image.nix"
  ];

  config = {
    rv32ima.machine.enable = true;
    rv32ima.machine.hostName = "ca-node";
    rv32ima.machine.stateVersion = "25.05";
    rv32ima.machine.platform = "x86_64-linux";

    users.allowNoPasswordLogin = true;

    systemd.packages = [ pkgs.step-ca ];

    # configuration file indirection is needed to support reloading
    environment.etc."smallstep/ca.json".source = configFile;

    systemd.services."step-ca" = {
      wantedBy = [ "multi-user.target" ];
      restartTriggers = [ configFile ];
      unitConfig = {
        ConditionFileNotEmpty = ""; # override upstream
      };
      serviceConfig = {
        User = "step-ca";
        Group = "step-ca";
        UMask = "0077";
        Environment = "HOME=%S/step-ca";
        WorkingDirectory = ""; # override upstream
        ReadWritePaths = ""; # override upstream

        ExecStart = [
          "" # override upstream
          "${pkgs.step-ca}/bin/step-ca /etc/smallstep/ca.json"
        ];

        # ProtectProc = "invisible"; # not supported by upstream yet
        # ProcSubset = "pid"; # not supported by upstream yet
        # PrivateUsers = true; # doesn't work with privileged ports therefore not supported by upstream

        DynamicUser = true;
        StateDirectory = "step-ca";
      };
    };

    users.users.step-ca = {
      home = "/var/lib/step-ca";
      group = "step-ca";
      isSystemUser = true;
    };

    users.groups.step-ca = { };

    services.step-ca.port = 443;
    services.step-ca.address = "0.0.0.0";
    services.step-ca.settings =
      let
        rootCA = pkgs.writeText "root_ca.crt" ''
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
        intermediateCA = pkgs.writeText "intermediate_ca.crt" ''
          -----BEGIN CERTIFICATE-----
          MIIBoDCCAUagAwIBAgIQSeRtJ8AbFbciT7MTwdK0NTAKBggqhkjOPQQDAjAaMRgw
          FgYDVQQDEw90NHQubmV0IFJvb3QgQ0EwHhcNMjUxMTAzMjAxNzI3WhcNMzUxMTAx
          MjAxNzI3WjAiMSAwHgYDVQQDExd0NHQubmV0IEludGVybWVkaWF0ZSBDQTBZMBMG
          ByqGSM49AgEGCCqGSM49AwEHA0IABE+T/PrnqPurM3mi18EEhE460CzqZrFTMuOQ
          gPtF7Stydt+E6Dz1QZ1xg8rvjcmQ8F3llvxcJYtA3SaY3TKKA1SjZjBkMA4GA1Ud
          DwEB/wQEAwIBBjASBgNVHRMBAf8ECDAGAQH/AgEAMB0GA1UdDgQWBBQB6QdaeLjt
          Q59g32jkcI+5P/5+LDAfBgNVHSMEGDAWgBTUwiWP6OubJ8G9pqDn0G8ondx8mTAK
          BggqhkjOPQQDAgNIADBFAiEA71xPfgSJUw/vwacXka2CqLeAl0GEuy3Pmt56xAZG
          YOQCIBxhnnLfeErShNxNxfTK8PZxpljXBtE6nQBoLP4VgYoY
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
                dns = [
                  "*.sea.t4t.net"
                  "*.t4t.net"
                ];
              };
              allowWildcardNames = true;
            };
          };
        };
        crt = "${intermediateCA}";
        db = {
          dataSource = "postgresql://step:oN4zb92aJv2cfMeo@ca-db20251103213835147500000001.ch2ea4oae4ax.us-west-2.rds.amazonaws.com:5432/";
          database = "step";
          type = "postgresql";
        };
        dnsNames = [ "ca.t4t.net" ];
        federatedRoots = null;
        insecureAddress = "";
        key = "awskms:key-id=e21f49a2-ef9f-4e87-9291-f5796f88727e";
        logger = {
          format = "text";
        };
        root = "${rootCA}";
        ssh = {
          hostKey = "awskms:key-id=f4f61975-422d-4f32-be56-33fe4a478b8e";
          userKey = "awskms:key-id=a369ada2-91e7-40fa-a40d-97b4613585cd";
        };
        kms = {
          type = "awskms";
          uri = "awskms:region=us-west-2";
        };
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

    networking.firewall.allowedTCPPorts = [
      config.services.step-ca.port
    ];
  };
}
