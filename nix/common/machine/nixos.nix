{
  stateVersion,
  ...
}:
{
  imports = [
    ./machine.nix
  ];

  system.stateVersion = stateVersion;
}
