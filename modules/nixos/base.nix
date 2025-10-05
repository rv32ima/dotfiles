{
  config,
  lib,
  ...
}:
{
  options = {
    rv32ima.machine.enable = lib.mkEnableOption "ellie's machine config";
    rv32ima.machine.domainName = lib.mkOption {
      type = lib.types.str;
      default = "core.t4t.net";
      description = "The domain name for this machine";
    };
    rv32ima.machine.hostName = lib.mkOption {
      type = lib.types.str;
      example = "fadeoutz";
      default = "";
      description = "The hostname for this machine";
    };
    rv32ima.machine.stateVersion = lib.mkOption {
      type = lib.types.str;
      default = "";
      description = "The state version for this machine";
    };
    rv32ima.machine.users = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [ ];
      description = "The users on this machine";
    };
    rv32ima.machine.isRemote = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Is this machine located locally or in a datacenter?";
    };
  };

  config = lib.mkIf config.rv32ima.machine.enable {
    system.stateVersion = config.rv32ima.machine.stateVersion;
    networking.hostName = config.rv32ima.machine.hostName;
    networking.domain = config.rv32ima.machine.domainName;
  };
}
