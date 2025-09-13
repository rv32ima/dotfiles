{
  machine,
  ...
}:
{
  imports = [
    ./users.nix
  ];

  system.stateVersion = machine.stateVersion;
}
