{
  machine,
  ...
}:
{
  imports = [
    ../shared/nix-config.nix
    ./users.nix
  ];

  system.stateVersion = machine.stateVersion;
}
