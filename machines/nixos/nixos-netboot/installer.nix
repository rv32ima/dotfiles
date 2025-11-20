{
  modulesPath,
  inputs,
  lib,
  ...
}:
{
  imports = [
    "${modulesPath}/installer/netboot/netboot-minimal.nix"
    ./default.nix
  ];
}
