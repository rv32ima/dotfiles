{
  self,
  config,
  lib,
  ...
}:
{
  options = {
    rv32ima.machine.bootstrapTarget = lib.mkOption {
      type = lib.types.str;
    };
  };

  config = {
    services.static-web-server = {
      enable = true;
      root = "${self.nixosConfigurations."${config.rv32ima.machine.bootstrapTarget}-installer".config.system.build.netboot
      }";
    };

    networking.firewall.allowedTCPPorts = [ 8787 ];
  };

}
