{
  description = "ellie's nix flake";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.11";
    nixpkgs-unstable.url = "github:NixOS/nixpkgs/nixos-unstable";
    nixpkgs-darwin.url = "github:NixOS/nixpkgs/nixpkgs-25.11-darwin";
    flake-utils.url = "github:numtide/flake-utils";
    nix-darwin = {
      url = "github:nix-darwin/nix-darwin/nix-darwin-25.11";
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
      url = "github:nix-community/home-manager/release-25.11";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    zig = {
      url = "github:mitchellh/zig-overlay";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    zls = {
      url = "github:zigtools/zls/0.15.0";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.zig-overlay.follows = "zig";
    };
    vscode-server = {
      url = "github:nix-community/nixos-vscode-server";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    disko = {
      url = "github:nix-community/disko";
    };
    nixos-wsl = {
      url = "github:nix-community/NixOS-WSL/main";
      inputs.nixpkgs.follows = "nixpkgs-unstable";
    };
    sops-nix.url = "github:Mic92/sops-nix";
    sops-nix.inputs.nixpkgs.follows = "nixpkgs";
    microvm.url = "github:microvm-nix/microvm.nix";
    microvm.inputs.flake-utils.follows = "flake-utils";
    colmena.url = "github:zhaofengli/colmena";
  };

  outputs =
    inputs@{
      nixpkgs,
      colmena,
      ...
    }:
    let
      lib = nixpkgs.lib;

      getMachineFiles =
        type:
        builtins.map
          (hostName: {
            inherit hostName;
            file = ./machines/${type}/${hostName}/default.nix;
          })
          (
            builtins.attrNames (lib.filterAttrs (_: v: v == "directory") (builtins.readDir ./machines/${type}))
          );
      nixosMachineFiles = getMachineFiles "nixos";
      darwinMachineFiles = getMachineFiles "darwin";
    in
    {
      darwinConfigurations = import ./darwin.nix {
        inherit inputs;
        machines = darwinMachineFiles;
      };

      nixosConfigurations = import ./nixos.nix {
        inherit inputs;
        machines = nixosMachineFiles;
      };

      colmenaHive = colmena.lib.makeHive inputs.self.outputs.colmena;

      colmena =
        let
          blacklistedNodes = [
            "golden-experience"
            "nixos-netboot"
            "ca-node"
          ];
          conf = lib.attrsets.filterAttrs (
            name: _:
            (lib.strings.hasSuffix "-installer" name) == false && (builtins.elem name blacklistedNodes) == false
          ) inputs.self.nixosConfigurations;
        in
        {
          meta = {
            nixpkgs = import nixpkgs { system = "x86_64-linux"; };
            nodeSpecialArgs = builtins.mapAttrs (_: value: value._module.specialArgs) conf;
            nodeNixpkgs = builtins.mapAttrs (_: value: value.pkgs) conf;
          };
        }
        // (builtins.mapAttrs (name: value: {
          imports = value._module.args.modules;
          deployment = import ./machines/nixos/${name}/deployment.nix;
        }) conf);

      devShells.aarch64-darwin = {
        default =
          let
            pkgs = import inputs.nixpkgs {
              system = "aarch64-darwin";
            };
          in
          pkgs.mkShell {
            packages = [
              colmena.packages.aarch64-darwin.colmena
            ];
          };
      };
    };
}
