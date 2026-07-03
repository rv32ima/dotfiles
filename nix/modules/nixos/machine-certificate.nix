{ config, ... }:
let
  fqdn = "${config.networking.hostName}.${config.networking.domain}";
in
{
  config = {
    rv32ima.machine.impermanence.extraPersistDirectories = [
      {
        path = /var/lib/acme;
        mode = "0755";
        owner = "acme";
        group = "acme";
      }
    ];

    security.acme.acceptTerms = true;
    security.acme.certs.${fqdn} = {
      email = "ellie@t4t.net";
      server = "https://ca.t4t.net/acme/acme/directory";
      listenHTTP = ":80";
    };

    networking.firewall.allowedTCPPorts = [ 80 ];
  };
}
