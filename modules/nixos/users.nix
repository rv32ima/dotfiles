{
  config,
  lib,
  inputs,
  ...
}:
lib.mkIf config.rv32ima.machine.enable {


  users.groups.trusted = { };
  # users in trusted group are trusted by the nix-daemon
  nix.settings.trusted-users = [ "@trusted" ];

  users.mutableUsers = false;
}
