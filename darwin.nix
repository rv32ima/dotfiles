{
  machines,
  inputs,
  ...
}:
let
  mkMachine =
    machine@{
      hostName,
      primaryUser,
      system,
      ...
    }:
    let
      pkgs = import ./modules/shared/nixpkgs.nix {
        nixpkgs = inputs.nixpkgs-darwin;
        inherit
          system
          inputs
          ;
      };
      specialArgs = {
        inherit (pkgs) lib;
        inherit
          pkgs
          machine
          inputs
          ;
      };
    in
    inputs.nix-darwin.lib.darwinSystem {
      inherit system specialArgs;
      modules = [
        inputs.nix-homebrew.darwinModules.nix-homebrew
        {
          nix-homebrew = {
            autoMigrate = true;
            enable = true;
            enableRosetta = true;
            user = primaryUser;
            taps = {
              "homebrew/homebrew-core" = inputs.homebrew-core;
              "homebrew/homebrew-cask" = inputs.homebrew-cask;
              "homebrew/homebrew-bundle" = inputs.homebrew-bundle;
            };
            mutableTaps = false;
          };
        }
        inputs.lix-module.nixosModules.default
        inputs.home-manager.darwinModules.home-manager
        {
          home-manager.useGlobalPkgs = true;
          home-manager.useUserPackages = true;
          home-manager.extraSpecialArgs = {
            inherit pkgs machine inputs;
          };
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
