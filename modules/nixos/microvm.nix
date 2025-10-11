{ inputs, ... }:
{
  imports = [
    inputs.microvm.nixosModules.host
  ];

  config = {
    microvm.host.enable = true;

    systemd.network.netdevs.virbr0.netdevConfig = {
      Kind = "bridge";
      Name = "virbr0";
    };

    systemd.network.networks.virbr0 = {
      matchConfig.Name = "virbr0";
      addresses = [
        {
          Address = "10.0.0.1/24";
        }
      ];

      networkConfig = {
        DHCPServer = true;
      };
    };

    systemd.network.networks.microvm = {
      matchConfig.Name = "vm-*";
      networkConfig.Bridge = "virbr0";
    };
    networking.firewall.interfaces.virbr0.allowedUDPPorts = [ 67 ];

    networking.nat.enable = true;
    networking.nat.enableIPv6 = true;
    networking.nat.internalInterfaces = [ "virbr0" ];
  };

}
