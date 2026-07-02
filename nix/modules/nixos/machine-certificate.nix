{ config, ... }:
let
  fqdn = "${config.networking.hostName}.${config.networking.domain}";
in
{
  config = {
    security.pki.certificates = [
      ''
        ca.t4t.net
        =========
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
      ''
    ];

    security.acme.acceptTerms = true;
    security.acme.certs.${fqdn} = {
      email = "ellie@t4t.net";
      server = "https://ca.t4t.net/acme/acme/directory";
      listenHTTP = ":80";
      group = "nginx";
    };

    networking.firewall.allowedTCPPorts = [ 80 ];
  };
}
