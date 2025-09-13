{ inputs, ... }:
{
  hostName = "fadeoutz";
  stateVersion = "25.05";
  system = "x86_64-linux";
  users = [
    "${inputs.self}/users/ellie.nix"
  ];
  isRemote = true;
}
