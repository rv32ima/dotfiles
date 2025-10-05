{
  machines,
  inputs,
  ...
}:
let
  mkCommon =
    machine@{
      system,
      hostName,
      configType,
      ...
    }:
    let
      configFile = if configType == "machine" then "default.nix" else "installer.nix";

      pkgs = import ./modules/shared/nixpkgs.nix {
        inherit
          system
          inputs
          ;
      };

      extraArgs = {
        inherit
          pkgs
          inputs
          machine
          system
          ;
      };

    in
    inputs.nixpkgs.lib.nixosSystem {
      inherit system;
      specialArgs = extraArgs;
      modules = [
        inputs.sops-nix.nixosModules.sops
        inputs.lix-module.nixosModules.default
        inputs.home-manager.nixosModules.home-manager
        {
          home-manager.useGlobalPkgs = true;
          home-manager.useUserPackages = true;
          home-manager.extraSpecialArgs = extraArgs;
        }
        ./modules/nixos/base.nix
        ./machines/${hostName}/${configFile}
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
