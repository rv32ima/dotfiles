inputs@{
  machines,
  lix-module,
  nixpkgs-darwin,
  zig,
  home-manager,
  rust-overlay,
  nix-darwin,
  nix-homebrew,
  homebrew-core,
  homebrew-cask,
  homebrew-bundle,
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
        nixpkgs = nixpkgs-darwin;
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
    nix-darwin.lib.darwinSystem {
      inherit system specialArgs;
      modules = [
        nix-homebrew.darwinModules.nix-homebrew
        {
          nix-homebrew = {
            autoMigrate = true;
            enable = true;
            enableRosetta = true;
            user = primaryUser;
            taps = {
              "homebrew/homebrew-core" = homebrew-core;
              "homebrew/homebrew-cask" = homebrew-cask;
              "homebrew/homebrew-bundle" = homebrew-bundle;
            };
            mutableTaps = false;
          };
        }
        lix-module.nixosModules.default
        home-manager.darwinModules.home-manager
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
