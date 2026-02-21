{
  machines,
  inputs,
  self,
  ...
}:
let
  mkCommon =
    {
      hostName,
      configType,
      ...
    }:
    let
      configFile = if configType == "machine" then "default.nix" else "installer.nix";
    in
    self.lib.nixosSystem' hostName ./machines/nixos/${hostName}/${configFile};
in
builtins.listToAttrs (
  builtins.concatLists (
    map (
      mI@{ hostName, ... }:
      (
        if builtins.pathExists ./machines/nixos/${hostName}/default.nix then
          [
            {
              name = hostName;
              value = mkCommon (
                mI
                // {
                  configType = "machine";
                }
              );
            }

          ]
        else
          [ ]
      )
      ++ (
        if builtins.pathExists ./machines/nixos/${hostName}/installer.nix then
          [
            {
              name = "${hostName}-installer";
              value = mkCommon (
                mI
                // {
                  configType = "installer";
                }
              );

            }

          ]
        else
          [ ]
      )
    ) machines
  )
)
