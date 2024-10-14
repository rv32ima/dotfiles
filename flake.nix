{
  description = "ellie's nix flake";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    nix-darwin = {
      url = "github:LnL7/nix-darwin";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    rust-overlay = {
      url = "github:oxalica/rust-overlay";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nix-darwin, nixpkgs, rust-overlay, home-manager, ... }:
  let
    lib = nixpkgs.lib; 
    common = { pkgs, ... }: {
      services.nix-daemon.enable = lib.mkDefault true;
      nix.settings.experimental-features = "nix-command flakes repl-flake";
      nix.settings.extra-sandbox-paths = [
        "/etc/nix/github_pat"
      ];
      nix.settings.trusted-users = [
        "ellie"
      ];

      system.configurationRevision = self.rev or self.dirtyRev or null;
    };

    buildMachines = {...}: {
      nix.buildMachines = [
        {
          hostName = "192.168.64.2";
          system = "aarch64-linux";
          sshUser = "root";
          publicHostKey = "c3NoLWVkMjU1MTkgQUFBQUMzTnphQzFsWkRJMU5URTVBQUFBSUFoUXhMb0xpQU5VVlNyZkZWTkhYK2VURExlTjNxYy9lR0kwdytoZk8ybjQgcm9vdEBuaXhvcwo=";
          sshKey = "/etc/nix/id_ed25519";
          maxJobs = 16;
          protocol = "ssh-ng";
        }
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

      nix.distributedBuilds = true;
    };

    rustOverlay = { pkgs, ...}: {
      nixpkgs.overlays = [ rust-overlay.overlays.default ];
    };
  in
  {
    darwinConfigurations."wallsocket" = nix-darwin.lib.darwinSystem {
      modules = [
        common
        buildMachines
        rustOverlay
        ./nix/wallsocket.nix
        home-manager.darwinModules.home-manager
        {
          home-manager.useGlobalPkgs = true;
          home-manager.useUserPackages = true;
          home-manager.users.ellie = import ./nix/ellie.nix;
        }
      ];
    };

    nixosConfigurations."ip-172.31.33.110" = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      modules = [
        common
        rustOverlay
        ./nix/pvm-builder.nix
        home-manager.nixosModules.home-manager
        {
          home-manager.useGlobalPkgs = true;
          home-manager.useUserPackages = true;
          home-manager.users.ellie = import ./nix/ellie.nix;
        }
      ];
    };
  };
}
