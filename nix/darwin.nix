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
      isRemote,
      ...
    }:
    let
      pkgs = import ./common/nixpkgs.nix {
        nixpkgs = nixpkgs-darwin;
        inherit
          system
          rust-overlay
          zig
          ;
      };
      specialArgs = (
        inputs
        // machine
        // {
          inherit pkgs;
        }
      );
      userFile = if isRemote then ./common/user/local.nix else ./common/user/remote.nix;
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
        ./common/machine/darwin.nix
        ./machines/${hostName}/default.nix
        home-manager.darwinModules.home-manager
        {
          home-manager.useGlobalPkgs = true;
          home-manager.useUserPackages = true;
          home-manager.extraSpecialArgs = specialArgs;
          home-manager.users."${primaryUser}" = {
            imports = [
              "${userFile}"
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
