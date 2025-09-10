{
  description = "ellie's nix flake";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.05";
    nixpkgs-darwin.url = "github:NixOS/nixpkgs/nixpkgs-25.05-darwin";
    flake-utils.url = "github:numtide/flake-utils";
    nix-darwin = {
      url = "github:nix-darwin/nix-darwin/nix-darwin-25.05";
      inputs.nixpkgs.follows = "nixpkgs-darwin";
    };
    nix-homebrew = {
      url = "github:zhaofengli-wip/nix-homebrew";
    };
    homebrew-core = {
      url = "github:homebrew/homebrew-core";
      flake = false;
    };
    homebrew-cask = {
      url = "github:homebrew/homebrew-cask";
      flake = false;
    };
    homebrew-bundle = {
      url = "github:homebrew/homebrew-bundle";
      flake = false;
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
    zig = {
      url = "github:mitchellh/zig-overlay";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    zls = {
      url = "github:zigtools/zls";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.zig-overlay.follows = "zig";
    };
    vscode-server = {
      url = "github:nix-community/nixos-vscode-server";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    inputs@{
      nix-darwin,
      nixpkgs,
      lix-module,
      rust-overlay,
      home-manager,
      zig,
      ...
    }:
    let
      lib = nixpkgs.lib;

      machineDescriptorFiles = builtins.filter (path: (builtins.baseNameOf path) == "machine.nix") (
        lib.filesystem.listFilesRecursive ./nix/machines
      );

      userFiles = lib.filesystem.listFilesRecursive ./nix/users;
      users = builtins.map (file: lib.strings.removeSuffix ".nix" (builtins.baseNameOf file)) userFiles;

      machines = builtins.map (path: import path { }) machineDescriptorFiles;
      isDarwin = system: lib.strings.hasSuffix "darwin" system;
      isLinux = system: lib.strings.hasSuffix "linux" system;
      darwinMachines = builtins.filter (machineConf: (isDarwin machineConf.system)) machines;
      linuxMachines = builtins.filter (machineConf: isLinux machineConf.system) machines;
    in
    {
      darwinConfigurations = import ./nix/darwin.nix (
        inputs
        // {
          machines = darwinMachines;
        }
      );

      nixosConfigurations = import ./nix/nixos.nix (
        inputs
        // {
          machines = linuxMachines;
        }
      );

      homeConfigurations = import ./nix/users.nix (
        inputs // {
          inherit users;
        }
      );
    };
}
