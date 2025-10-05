{
  config,
  lib,
  ...
}:
{
  options = {
    rv32ima.machine.linux-builder.enable = lib.mkEnableOption "the linux builder";
  };

  config = lib.mkIf config.rv32ima.machine.linux-builder.enable {
    nix.linux-builder.enable = true;
    nix.linux-builder.config.virtualisation.cores = config.nix.settings.max-jobs or 10;
    nix.linux-builder.systems = [
      "aarch64-linux"
    ];
    nix.distributedBuilds = true;
  };
}
