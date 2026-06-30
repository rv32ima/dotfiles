{ pkgs, lib, ... }:
let
  prefixes = [
    {
      family = "ipv4";
      prefix = "23.190.72.0/24";
      nexthop = "0.0.0.0";
    }
    {
      family = "ipv6";
      prefix = "2620:c2:2000::/48";
      nexthop = "::";
    }
  ];
in
{
  services.gobgpd = {
    enable = true;
    settings = {
      global.config = {
        as = 395388;
        router-id = "199.255.18.181";
      };

      peer-groups = [
        {
          config = {
            peer-group-name = "cofractal";
            peer-as = 26073;
          };
          afi-safis = [
            { config.afi-safi-name = "ipv4-unicast"; }
            { config.afi-safi-name = "ipv6-unicast"; }
          ];
          apply-policy.config = {
            default-import-policy = "accept-route";
            export-policy-list = [ "EXPORT" ];
            default-export-policy = "reject-route";
          };
        }
      ];

      neighbors = [
        {
          config = {
            neighbor-address = "2606:7940:32:3c::2";
            peer-group = "cofractal";
          };
        }
        {
          config = {
            neighbor-address = "2606:7940:32:3c::3";
            peer-group = "cofractal";
          };
        }
      ];

      # match the lo prefixes — gobgp has no interface matching
      defined-sets.prefix-sets = [
        {
          prefix-set-name = "lo-prefixes";
          prefix-list = map (p: {
            ip-prefix = p.prefix;
            masklength-range =
              let
                mask = lib.last (lib.splitString "/" p.prefix);
              in
              "${mask}..${mask}";
          }) prefixes;
        }
      ];

      policy-definitions = [
        {
          name = "EXPORT";
          statements = [
            {
              name = "permit-lo-with-v6-nexthop";
              conditions.match-prefix-set = {
                prefix-set = "lo-prefixes";
                match-set-options = "any";
              };
              actions = {
                route-disposition = "accept-route";
                # RFC 5549: ipv4 routes with ipv6 nexthop over ipv6 session.
                # extended-nexthop capability is auto-negotiated since transport is ipv6.
                bgp-actions.set-next-hop = "2606:7940:32:3c::11";
              };
            }
            {
              name = "deny-rest";
              actions.route-disposition = "reject-route";
            }
          ];
        }
      ];
    };
  };

  # gobgp has no kernel RIB redistribution, so inject lo prefixes on start.
  # nexthops here are dummies — the EXPORT policy sets the real one.
  systemd.services."gobgpd-inject-routes" = {
    after = [ "gobgpd.service" ];
    bindsTo = [ "gobgpd.service" ];
    wantedBy = [ "gobgpd.service" ];
    path = [ pkgs.gobgp ];
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
    };
    script = ''
      for i in $(seq 30); do
        gobgp global 2>/dev/null && break
        [ "$i" -eq 30 ] && echo "gobgpd not ready after 30s, giving up" && exit 1
        sleep 1
      done
      ${lib.concatMapStrings (
        p: "gobgp global rib add -a ${p.family} ${p.prefix} nexthop ${p.nexthop}\n"
      ) prefixes}
    '';
  };
}
