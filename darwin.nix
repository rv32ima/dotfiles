{
  machines,
  inputs,
  self,
  ...
}:
let
  mkMachine =
    {
      hostName,
      file,
      ...
    }:
    let
      specialArgs = {
        inherit
          inputs
          self
          ;
      };
    in
    inputs.nix-darwin.lib.darwinSystem {
      inherit specialArgs;
      modules = [
        inputs.sops-nix.darwinModules.sops
        inputs.nix-homebrew.darwinModules.nix-homebrew
        (
          { config, ... }:
          {
            nix-homebrew = {
              autoMigrate = true;
              enable = true;
              enableRosetta = true;
              user = config.rv32ima.machine.primaryUser;
              taps = {
                "homebrew/homebrew-core" = inputs.homebrew-core;
                "homebrew/homebrew-cask" = inputs.homebrew-cask;
                "homebrew/homebrew-bundle" = inputs.homebrew-bundle;
              };
              mutableTaps = false;
            };
          }
        )
        inputs.home-manager.darwinModules.home-manager
        {
          home-manager.useGlobalPkgs = true;
          home-manager.useUserPackages = true;
          home-manager.extraSpecialArgs = {
            inherit inputs;
          };
        }
        ./modules/darwin/default.nix
        file
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
