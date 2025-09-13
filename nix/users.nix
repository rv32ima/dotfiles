inputs@{
  users,
  home-manager,
  nixpkgs,
  rust-overlay,
  zig,
  lix-module,
  ...
}:
let
  systems = [
    "x86_64-linux"
    "aarch64-linux"
    "aarch64-darwin"
  ];
  common = {
    # inherit (nixpkgs) lib;
    inherit
      inputs
      nixpkgs
      home-manager
      lix-module
      ;
  };

  mkUser =
    { system, user, ... }:
    home-manager.lib.homeManagerConfiguration {
      pkgs = import ./common/nixpkgs.nix {
        inherit
          system
          nixpkgs
          rust-overlay
          zig
          ;
      };
      extraSpecialArgs = common // {
        inherit system;
      };
      modules = [
        ./common/user/remote.nix
        ./users/${user}.nix
      ];
    };
in
builtins.foldl' nixpkgs.lib.recursiveUpdate { } (
  builtins.map (
    system:
    builtins.listToAttrs (
      map (user: {
        name = "${user}-${system}";
        value = mkUser {
          inherit system user;
        };
      }) users
    )
  ) systems
)
