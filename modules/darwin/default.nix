{
  machine,
  ...
}:
{
  imports = [
    ../shared/nix-config.nix
    ./users.nix
    ./linux-builder.nix
  ];

  system = {
    inherit (machine) stateVersion primaryUser;
  };
}
