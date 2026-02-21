{
  machines,
  inputs,
  self,
  ...
}:
let
  mkMachine =
    {
      hostName,
      file,
      ...
    }:
    self.lib.darwinSystem' hostName file;
in
builtins.listToAttrs (
  map (
    mI@{ hostName, ... }:
    {
      name = hostName;
      value = mkMachine mI;
    }
  ) machines
)
