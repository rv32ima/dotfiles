{ machine, ... }:
{
  imports = machine.users;

  users.groups.trusted = { };
  # users in trusted group are trusted by the nix-daemon
  nix.settings.trusted-users = [ "@trusted" ];
}
