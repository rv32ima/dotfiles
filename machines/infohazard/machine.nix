{ inputs, ... }:
{
  hostName = "infohazard";
  stateVersion = 6;
  primaryUser = "ellie";
  users = [
    "${inputs.self}/users/ellie.nix"
  ];
  system = "aarch64-darwin";
  isRemote = false;
}
