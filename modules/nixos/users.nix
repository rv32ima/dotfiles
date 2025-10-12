{
  config,
  lib,
  inputs,
  ...
}:
{
  imports = builtins.map (user: "${inputs.self}/users/${user}/default.nix") (
    builtins.attrNames (
      lib.filterAttrs (_: v: v == "directory") (builtins.readDir "${inputs.self}/users")
    )
  );

  config = lib.mkIf config.rv32ima.machine.enable {
    users.groups.trusted = { };
    # users in trusted group are trusted by the nix-daemon
    nix.settings.trusted-users = [ "@trusted" ];

    users.mutableUsers = false;
  };
}
