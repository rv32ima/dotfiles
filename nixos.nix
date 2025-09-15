{
  machines,
  inputs,
  ...
}:
let
  mkMachine =
    machine@{
      system,
      hostName,
      ...
    }:
    let
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
        inputs.lix-module.nixosModules.default
        inputs.home-manager.nixosModules.home-manager
        {
          home-manager.useGlobalPkgs = true;
          home-manager.useUserPackages = true;
          home-manager.extraSpecialArgs = extraArgs;
        }
        ./machines/${hostName}/default.nix
      ];
    };
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
