primaryUser:
{
  lib,
  pkgs,
  stateVersion,
  ...
}:
{
  imports = [
    (import ./common.nix primaryUser)
  ];
}
