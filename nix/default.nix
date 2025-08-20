{
  inputs,
  hosts,
  lix-module,
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
        nix.package = pkgs.lix;
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
              {
                hostName = "linux-builder";
                system = "aarch64-linux";
                sshUser = "builder";
                publicHostKey = "c3NoLWVkMjU1MTkgQUFBQUMzTnphQzFsWkRJMU5URTVBQUFBSUpCV2N4Yi9CbGFxdDFhdU90RStGOFFVV3JVb3RpQzVxQkorVXVFV2RWQ2Igcm9vdEBuaXhvcwo=";
                sshKey = "/etc/nix/builder_ed25519";
                maxJobs = 24;
                protocol = "ssh-ng";
                supportedFeatures = [
                  "kvm"
                  "benchmark"
                  "big-parallel"
                ];
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
          lix-module.nixosModules.default
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
          lix-module.nixosModules.default
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
