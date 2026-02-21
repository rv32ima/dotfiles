{
  description = "ellie's nix flake";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.11";
    nixpkgs-unstable.url = "github:NixOS/nixpkgs/nixos-unstable";
    nixpkgs-darwin.url = "github:NixOS/nixpkgs/nixpkgs-25.11-darwin";
    flake-utils.url = "github:numtide/flake-utils";
    flake-parts.url = "github:hercules-ci/flake-parts";
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
    sops-nix = {
      url = "github:Mic92/sops-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    microvm = {
      url = "github:microvm-nix/microvm.nix";
      inputs.flake-utils.follows = "flake-utils";
    };
    colmena.url = "github:zhaofengli/colmena";
    darwin-ssh-askpass = {
      url = "github:theseal/homebrew-ssh-askpass";
      flake = false;
    };
  };

  outputs =
    inputs@{
      self,
      nixpkgs,
      flake-parts,
      colmena,
      nix-darwin,
      ...
    }:
    flake-parts.lib.mkFlake { inherit inputs; } (
      { inputs, ... }:
      {
        systems = [
          "x86_64-linux"
          "aarch64-darwin"
        ];

        flake =
          let
            inherit (inputs) colmena;
            lib = nixpkgs.lib;

            getMachineFiles =
              type:
              builtins.attrNames (lib.filterAttrs (_: v: v == "directory") (builtins.readDir ./machines/${type}));

            nixosMachineFiles = getMachineFiles "nixos";
            darwinMachineFiles = getMachineFiles "darwin";
          in
          {
            darwinConfigurations = builtins.listToAttrs (
              map (hostName: {
                name = hostName;
                value = self.lib.darwinSystem' hostName ./machines/darwin/${hostName}/default.nix;
              }) darwinMachineFiles
            );

            nixosConfigurations = builtins.listToAttrs (
              builtins.concatLists (
                map (
                  hostName:
                  (
                    if builtins.pathExists ./machines/nixos/${hostName}/default.nix then
                      [
                        {
                          name = hostName;
                          value = self.lib.nixosSystem' hostName ./machines/nixos/${hostName}/default.nix;
                        }
                      ]
                    else
                      [ ]
                  )
                  ++ (
                    if builtins.pathExists ./machines/nixos/${hostName}/installer.nix then
                      [
                        {
                          name = "${hostName}-installer";
                          value = self.lib.nixosSystem' hostName ./machines/nixos/${hostName}/installer.nix;

                        }

                      ]
                    else
                      [ ]
                  )
                ) nixosMachineFiles
              )
            );

            colmenaHive = colmena.lib.makeHive self.outputs.colmena;

            colmena =
              let
                blacklistedNodes = [
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
                deployment = self.lib.vars.machines.${name}.deployment or { };
              }) conf);

            lib = {
              vars = {
                machines = import ./vars/machines.nix inputs;
              };

              nixosSystem =
                machineName: self.lib.nixosSystem' machineName ./machines/nixos/${machineName}/configuration.nix;

              nixosSystem' =
                machineName: machineModule:
                nixpkgs.lib.nixosSystem {
                  modules = [
                    { networking.hostName = machineName; }
                    (self.lib.nixosModule "nixos/base")
                    machineModule
                  ];
                  specialArgs = {
                    inherit self inputs;
                    vars = self.lib.vars;
                    vars' = self.lib.vars.machines.${machineName} or { };
                  };
                };

              darwinSystem =
                machineName: self.lib.darwinSystem' machineName ./machines/${machineName}/configuration.nix;

              darwinSystem' =
                machineName: machineModule:
                nix-darwin.lib.darwinSystem {
                  modules = [
                    { networking.hostName = machineName; }
                    (self.lib.nixosModule "darwin/base")
                    machineModule
                  ];
                  specialArgs = {
                    inherit self inputs;
                    vars = self.lib.vars;
                    vars' = self.lib.vars.machines.${machineName} or { };
                  };
                };

              nixosModule =
                name:
                if builtins.pathExists ./modules/${name}/default.nix then
                  import ./modules/${name}/default.nix
                else if builtins.pathExists ./modules/${name}.nix then
                  import ./modules/${name}.nix
                else
                  throw "NixOS module '${name}' not found in modules directory";
            };

          };

        perSystem =
          {
            pkgs,
            system,
            ...
          }:
          {
            devShells.default = pkgs.mkShell {
              packages = [
                colmena.packages.${system}.colmena
              ];
            };
          };
      }
    );
}
