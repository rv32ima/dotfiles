{
  machines,
  inputs,
  ...
}:
let
  lib = inputs.nixpkgs.lib;
  mkCommon =
    machine@{
      hostName,
      configType,
      ...
    }:
    let
      configFile = if configType == "machine" then "default.nix" else "installer.nix";

      extraArgs = {
        inherit
          inputs
          machine
          ;
      };

    in
    inputs.nixpkgs.lib.nixosSystem {
      specialArgs = extraArgs;
      modules = [
        inputs.sops-nix.nixosModules.sops
        inputs.home-manager.nixosModules.home-manager
        {
          home-manager.useGlobalPkgs = true;
          home-manager.useUserPackages = true;
          home-manager.extraSpecialArgs = extraArgs;
        }
        ./modules/nixos/default.nix
        ./machines/nixos/${hostName}/${configFile}
      ];
    };
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
