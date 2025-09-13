{ inputs }:
{
  hostName = "6fingerdeathpunch";
  stateVersion = 6;
  primaryUser = "eford";
  system = "aarch64-darwin";
  users = [
    "${inputs.self}/users/eford.nix"
  ];
  isRemote = false;
}
