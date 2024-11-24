{
  description = "ellie's nix flake";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    flake-utils.url = "github:numtide/flake-utils";
    nix-darwin = {
      # TODO: when https://github.com/LnL7/nix-darwin/pull/1168 is merged, revert back
      url = "github:talhaHavadar/nix-darwin/0a3df54053439f76c1d6ef1cf44b0df767b13c3e";
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

  outputs =
    inputs @ {
      self,
      nix-darwin,
      nixpkgs,
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
        { name = "wallsocket"; system = "aarch64-darwin"; stateVersion = "24.05"; remote = false; }
      ];

      systems = [
        "aarch64-darwin"
        "aarch64-linux"
        "x86_64-linux"
      ];

      common = user: {
        inherit (nixpkgs) lib;
        inherit inputs nixpkgs home-manager nix-darwin hosts user;
      };

      mkUser = { user, system, ... }: home-manager.lib.homeManagerConfiguration {
        pkgs = import nixpkgs {
          inherit system;
          config = {
            allowUnfree = true;
          };
          overlays = [
            inputs.rust-overlay.overlays.default
          ];
        };
        extraSpecialArgs = (common user) // { stateVersion = "24.05"; inherit system; };
        modules = [
          ./nix/home.nix
        ];
      };
        
    in
    ({
      darwinConfigurations = import ./nix ( common "ellie" // {
        isDarwin = true;
      });
    } // 
    flake-utils.lib.eachSystem systems (system: {
      packages.homeConfigurations = builtins.listToAttrs(map (user: { name = user; value = mkUser { inherit user system; }; }) users);
    })
  );
}
