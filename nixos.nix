{
  machines,
  inputs,
  ...
}:
let
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
        ./modules/nixos/base.nix
        ./machines/nixos/${hostName}/${configFile}
      ];
    };
in
builtins.listToAttrs (
  map (
    mI@{ hostName, ... }:
    {
      name = hostName;
      value = {
        machine = mkCommon (
          mI
          // {
            configType = "machine";
          }
        );
        installer = mkCommon (
          mI
          // {
            configType = "installer";
          }
        );
      };
    }
  ) machines
)
