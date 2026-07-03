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
        ${builtins.readFile ../../../certificates/root-ca.crt}
      ''
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
