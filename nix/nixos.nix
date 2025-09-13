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
      isRemote,
      primaryUser ? null,
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
        // {
          inherit
            pkgs
            inputs
            stateVersion
            hostName
            system
            isRemote
            primaryUser
            ;
        }
      );

      userFile = if isRemote then ./common/user/local.nix else ./common/user/remote.nix;

      hmUser =
        if (primaryUser != null) then
          {
            home-manager.users."${primaryUser}" = {
              imports = [
                "${userFile}"
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
