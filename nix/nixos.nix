{
  inputs,
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
      hostName,
      stateVersion,
      primaryUser,
      system,
      ...
    }:
    let
      pkgs = import ./common/nixpkgs.nix {
        inherit
          system
          nixpkgs
          rust-overlay
          zig
          ;
      };

      extraArgs = (
        inputs
        // machine
        // {
          inherit
            pkgs
            inputs
            primaryUser
            stateVersion
            ;
        }
      );
    in
    nixpkgs.lib.nixosSystem {
      inherit system;
      specialArgs = extraArgs;
      modules = [
        lix-module.nixosModules.default
        ./common/machine/nixos.nix
        ./machines/${hostName}/default.nix
        home-manager.nixosModules.home-manager
        {
          home-manager.useGlobalPkgs = true;
          home-manager.useUserPackages = true;
          home-manager.extraSpecialArgs = extraArgs;
          home-manager.users."${primaryUser}" = {
            imports = [
              ./users/${primaryUser}.nix
            ];
          };
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
