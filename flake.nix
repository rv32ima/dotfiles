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
    vscode-server = {
      url = "github:nix-community/nixos-vscode-server";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nix-darwin, nixpkgs, rust-overlay, home-manager, vscode-server, ... }:
  let
    lib = nixpkgs.lib; 
    common = { pkgs, ... }: {
      nix.settings.experimental-features = "nix-command flakes repl-flake";
      nix.settings.trusted-users = [
        "ellie"
        "nix"
      ];

      system.configurationRevision = self.rev or self.dirtyRev or null;
    };

    stupidFuckingNixHack = { ... }: {
      nix.settings.extra-sandbox-paths = [
        "/etc/nix/github_pat"
      ];
    };

    buildMachines = {...}: {
      nix.buildMachines = [
        {
          hostName = "imaginal-disk.net.ellie.fm";
          system = "aarch64-linux";
          sshUser = "nix";
          publicHostKey = "c3NoLWVkMjU1MTkgQUFBQUMzTnphQzFsWkRJMU5URTVBQUFBSUhROHVGM1JpQ0k2cWErV1gzdGxrQi9jL2UwbzV1QWdCV2hTNi96QlZnSC8gcm9vdEBpbWFnaW5hbGRpc2sK";
          sshKey = "/etc/nix/id_ed25519";
          maxJobs = 128;
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
        stupidFuckingNixHack
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

    nixosConfigurations."ip-172-31-33-110.ec2.internal" = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      modules = [
        common
        rustOverlay
        vscode-server.nixosModules.default
        ./nix/pvm-builder.nix
        home-manager.nixosModules.home-manager
        {
          home-manager.useGlobalPkgs = true;
          home-manager.useUserPackages = true;
          home-manager.users.ellie = import ./nix/ellie.nix;
        }
      ];
    };

    nixosConfigurations."imaginal-disk" = nixpkgs.lib.nixosSystem {
      system = "aarch64-linux";
      modules = [
        common
        rustOverlay
        buildMachines
        vscode-server.nixosModules.default
        ./nix/imaginal-disk/configuration.nix
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
