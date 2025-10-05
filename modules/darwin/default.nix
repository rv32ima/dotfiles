{
  config,
  inputs,
  ...
}:
{
  imports = [
    ../shared/nix-config.nix
    ../shared/nixpkgs.nix
    ./base.nix
    ./users.nix
    ./linux-builder.nix
    ./workstation.nix
  ];
}
