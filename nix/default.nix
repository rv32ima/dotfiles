{
  lib,
  inputs,
  hosts,
  nixpkgs,
  home-manager,
  nix-darwin,
  isDarwin,
  user,
  ...
}:
let
  nixpkgConf =
    system:
    import nixpkgs {
      inherit system;
      config = {
        allowUnfree = true;
      };
      overlays = [
        inputs.rust-overlay.overlays.default
        inputs.jujutsu.overlays.default
      ];
    };

  mkHost =
    {
      name,
      stateVersion,
      system,
      remote,
    }:
    let
      pkgs = nixpkgConf system;
      nixCommon = {
        nix.settings.experimental-features = "nix-command flakes";
        nix.settings.trusted-users = [
          "${user}"
          "nix"
        ];
        nix.settings.extra-sandbox-paths = [
          "/etc/nix/github_pat"
        ];
        nix.buildMachines =
          if remote then
            [ ]
          else
            [
              {
                hostName = "stardust";
                system = "x86_64-linux";
                sshUser = "nix";
                publicHostKey = "c3NoLWVkMjU1MTkgQUFBQUMzTnphQzFsWkRJMU5URTVBQUFBSUpMTGtJM2dET3dyWVREcWZwQ2hPOTRjV0dTWEF4czlTMjdpck8vZzdxaWIgCg==";
                sshKey = "/etc/nix/id_ed25519";
                maxJobs = 16;
                protocol = "ssh-ng";
              }
            ];
        nix.distributedBuilds = !remote;
      };

      extraArgs = {
        inherit
          pkgs
          inputs
          user
          stateVersion
          ;
      };
    in
    if isDarwin then
      nix-darwin.lib.darwinSystem {
        inherit system;
        specialArgs = extraArgs;
        modules = [
          nixCommon
          ./hosts/${name}
          home-manager.darwinModules.home-manager
          {
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
            home-manager.extraSpecialArgs = extraArgs;
            home-manager.users."${user}" = {
              imports = [
                ./home.nix
              ];
            };
          }
        ];
      }
    else
      nixpkgs.lib.nixosSystem {
        inherit system;
        specialArgs = extraArgs;
        modules = [
          nixCommon
          ./hosts/${name}
          home-manager.nixosModules.home-manager
          {
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
            home-manager.extraSpecialArgs = extraArgs;
            home-manager.users."${user}" = {
              imports = [
                ./home.nix
              ];
            };
          }
        ];
      };
in
builtins.listToAttrs (
  map (
    mI@{ name, ... }:
    {
      inherit name;
      value = mkHost mI;
    }
  ) hosts
)
