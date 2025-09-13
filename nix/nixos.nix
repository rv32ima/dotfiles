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
      hostName,
      stateVersion,
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
      lib = nixpkgs.lib;

      extraArgs = (
        inputs
        // machine
        // {
          inherit
            pkgs
            inputs
            stateVersion
            ;
        }
      );

      hmUser =
        let
          primaryUser = machine.primaryUser ? null;
        in
        if (primaryUser != null) then
          {
            home-manager.users."${primaryUser}" = {
              imports = [
                (import ./common/user.nix
                ./users/${primaryUser}.nix
              ];
            };
          }
        else
          { };
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
        }
        hmUser
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
