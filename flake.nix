{
  description = "ellie's nix flake";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-25.05-darwin";
    flake-utils.url = "github:numtide/flake-utils";
    nix-darwin = {
      url = "github:nix-darwin/nix-darwin/nix-darwin-25.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    rust-overlay = {
      url = "github:oxalica/rust-overlay";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    home-manager = {
      url = "github:nix-community/home-manager/release-25.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    lix-module = {
      url = "https://git.lix.systems/lix-project/nixos-module/archive/2.93.3-1.tar.gz";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    vscode-server = {
      url = "github:nix-community/nixos-vscode-server";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    inputs@{
      self,
      nix-darwin,
      nixpkgs,
      lix-module,
      rust-overlay,
      home-manager,
      vscode-server,
      flake-utils,
      ...
    }:
    let
      users = [
        "ellie"
        "devzero"
      ];

      hosts = [
        {
          name = "wallsocket";
          system = "aarch64-darwin";
          stateVersion = "24.05";
          remote = false;
        }
        {
          name = "icedancer";
          system = "aarch64-darwin";
          stateVersion = "24.05";
          remote = false;
        }
      ];

      systems = [
        "aarch64-darwin"
        "aarch64-linux"
        "x86_64-linux"
      ];

      common = user: {
        # inherit (nixpkgs) lib;
        inherit
          inputs
          nixpkgs
          home-manager
          lix-module
          nix-darwin
          hosts
          user
          ;
      };

      mkUser =
        { user, system, ... }:
        home-manager.lib.homeManagerConfiguration {
          pkgs = import nixpkgs {
            inherit system;
            config = {
              allowUnfree = true;
            };
            overlays = [
              inputs.rust-overlay.overlays.default
            ];
          };
          extraSpecialArgs = (common user) // {
            stateVersion = "24.05";
            inherit system;
          };
          modules = [
            ./nix/home.nix
          ];
        };

    in
    (
      {
        darwinConfigurations = import ./nix (
          common "ellie"
          // {
            isDarwin = true;
          }
        );
      }
      // flake-utils.lib.eachSystem systems (system: {
        packages.homeConfigurations = builtins.listToAttrs (
          map (user: {
            name = user;
            value = mkUser { inherit user system; };
          }) users
        );
      })
    );
}
