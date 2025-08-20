{
  inputs,
  machines,
  lix-module,
  nixpkgs,
  home-manager,
  nix-darwin,
  isDarwin,
  ...
}:
let
  lib = nixpkgs.lib;

  mkMachine =
    {
      hostName,
      stateVersion,
      primaryUser,
      system,
      remote,
    }:
    let
      pkgs = import ./common/nixpkgs.nix {
        inherit system nixpkgs rust-overlay;
      };

      extraArgs = {
        inherit
          pkgs
          inputs
          primaryUser
          stateVersion
          ;
      };
    in nixpkgs.lib.nixosSystem {
        inherit system;
        specialArgs = extraArgs;
        modules = [
          lix-module.nixosModules.default
          ./common/default.nix
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
