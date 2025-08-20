inputs@{
  machines,
  lix-module,
  nixpkgs,
  home-manager,
  rust-overlay,
  nix-darwin,
  ...
}:
let
  lib = nixpkgs.lib;

  mkMachine =
    machine@{
      hostName,
      stateVersion,
      primaryUser,
      system,
      isRemote,
      ...
    }: 
    let
      pkgs = import ./common/nixpkgs.nix {
        inherit system rust-overlay nixpkgs;
      };
      specialArgs = (inputs // machine // {
        inherit pkgs;
      });
    in nix-darwin.lib.darwinSystem {
        inherit system specialArgs;
        modules = [
          lix-module.nixosModules.default
          ./common/default.nix
          ./machines/${hostName}/default.nix
          home-manager.darwinModules.home-manager
          {
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
            home-manager.extraSpecialArgs = specialArgs;
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
