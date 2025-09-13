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
        inherit (nixpkgs) lib;
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
        lix-module.nixosModules.default
        ./machines/${hostName}/default.nix
        home-manager.nixosModules.home-manager
        {
          home-manager.useGlobalPkgs = true;
          home-manager.useUserPackages = true;
          home-manager.extraSpecialArgs = extraArgs;
        }
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
