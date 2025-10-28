{
  ...
}:
{
  imports = [
    ../shared/nix-config.nix
    ../shared/nixpkgs.nix
    ./base.nix
    ./users.nix
    ./remote-builder.nix
    ./zfs-mirror.nix
    ./impermanence.nix
    ./netboot.nix
  ];
}
