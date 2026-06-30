{ lib, ... }:
{
  networking.useDHCP = lib.mkDefault false;
  networking.useNetworkd = true;
  networking.firewall.checkReversePath = "loose";

  systemd.network.networks."01-vpro-oob-ethernet" = {
    enable = true;
    matchConfig.PermanentMACAddress = "38:05:25:38:07:AE";
    DHCP = "yes";
  };

  systemd.network.netdevs."bond0".netdevConfig = {
    Kind = "bond";
    Name = "bond0";
    MACAddress = "38:05:25:37:2b:d0";
  };

  systemd.network.netdevs."bond0".bondConfig = {
    Mode = "802.3ad";
    TransmitHashPolicy = "layer3+4";
    LACPTransmitRate = "fast";
  };

  systemd.network.networks."bond0-eno1np0" = {
    matchConfig.Name = "eno1np0";
    networkConfig.Bond = "bond0";
  };

  systemd.network.networks."bond0-eno2np1" = {
    matchConfig.Name = "eno2np1";
    networkConfig.Bond = "bond0";
  };

  systemd.network.networks."bond0" = {
    matchConfig.Name = "bond0";

    networkConfig = {
      DHCP = true;
      IPv6AcceptRA = true;
    };

    dhcpV6Config.WithoutRA = "solicit";

    routes = [
      {
        Destination = "2620:C2:2000::1/64";
      }
      {
        Gateway = "2620:C2:2000::1";
      }
    ];
  };

  systemd.network.netdevs."home-wg" = {
    netdevConfig = {
      Kind = "wireguard";
      Name = "home-wg";
    };
    wireguardConfig = {
      ListenPort = 51820;
      RouteTable = "main";
      PrivateKeyFile = "/persist/etc/wireguard/secret.key";
    };
    wireguardPeers = [
      {
        AllowedIPs = [
          "10.100.0.2/32"
        ];
        PublicKey = "XbQNGT/bWtBJ/4i3UupI7tsMHUevYcbkHJwTv7QUVDY=";
      }
    ];
  };

  networking.firewall.allowedUDPPorts = [ 51820 ];

  systemd.network.networks."home-wg" = {
    matchConfig.Name = "home-wg";

    networkConfig.Tunnel = "home-sit";

    address = [
      "10.100.0.1/32"
    ];
  };

  boot.kernelModules = [
    "sit"
  ];

  systemd.network.netdevs."home-sit" = {
    netdevConfig = {
      Kind = "sit";
      Name = "home-sit";
      MTUBytes = 1400;
    };
    tunnelConfig = {
      Local = "10.100.0.1";
      Remote = "10.100.0.2";
      TTL = 255;
    };
  };

  systemd.network.networks."home-sit" = {
    matchConfig.Name = "home-sit";
    addresses = [
      {
        Address = "2620:c2:2000::2/64";
      }
    ];

    linkConfig = {
      MTUBytes = 1400;
    };

    routes = [
      {
        Destination = "2620:c2:2000:1::/64";
      }
    ];
  };

  boot.kernel.sysctl = {
    "net.ipv4.ip_forward" = "1";
    "net.ipv6.conf.all.forwarding" = "1";
    "net.ipv6.conf.default.forwarding" = "1";
  };

  networking.firewall.trustedInterfaces = [
    "home-wg"
    "home-sit"
  ];
}
