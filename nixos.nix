inputs@{
  machines,
  lix-module,
  nixpkgs,
  home-manager,
  rust-overlay,
  zig,
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
          ;
      };

    in
    nixpkgs.lib.nixosSystem {
      inherit system;
      specialArgs = extraArgs;
      modules = [
        pkgs.nixosModules.readOnlyPkgs
        {
          nixpkgs.pkgs = pkgs;
        }
        lix-module.nixosModules.default
        home-manager.nixosModules.home-manager
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
