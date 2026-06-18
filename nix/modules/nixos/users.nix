{
  config,
  lib,
  ...
}:
{
  config = lib.mkIf config.rv32ima.machine.enable {

  };
}
