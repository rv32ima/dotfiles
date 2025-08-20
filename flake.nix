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
      lib = nixpkgs.lib;

      machineDescriptorFiles = builtins.filter 
        (path: (builtins.baseNameOf path) == "machine.nix")
        (lib.filesystem.listFilesRecursive ./nix/machines);
      
      machines = builtins.map (path: import path {}) machineDescriptorFiles;
      isDarwin = system: lib.strings.hasSuffix "darwin" system;
      isLinux = system: lib.strings.hasSuffix "linux" system;
      darwinMachines = builtins.filter (machineConf: (isDarwin machineConf.system)) machines;
      linuxMachines = builtins.filter (machineConf: isLinux machineConf.system) machines;

      common = {
        # inherit (nixpkgs) lib;
        inherit
          inputs
          nixpkgs
          home-manager
          lix-module
          nix-darwin
          machines;
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
            inherit system;
          };
          modules = [
            ./nix/home.nix
          ];
        };
    in
      {
        darwinConfigurations = import ./nix/darwin.nix (inputs // {
          machines = darwinMachines;
        });
      };
}
