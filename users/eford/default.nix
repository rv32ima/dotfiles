{
  pkgs,
  machine,
  options,
  config,
  lib,
  inputs,
  ...
}:
let
  homeDirectory = if (lib.hasSuffix "darwin" machine.system) then "/Users" else "/home";
in
lib.mkIf (builtins.elem "eford" config.rv32ima.machine.users) {
  programs.fish.enable = true;
  programs.fish.useBabelfish = true;

  users.users."eford" = {
    shell = pkgs.fish;
    home = "${homeDirectory}/eford";
    createHome = true;
  }
  // lib.optionalAttrs (builtins.hasAttr "extraGroups" (options.users.users.type.getSubOptions { })) {
    extraGroups = [
      "wheel"
      "trusted"
    ];
  }
  //
    lib.optionalAttrs (builtins.hasAttr "isNormalUser" (options.users.users.type.getSubOptions { }))
      {
        isNormalUser = true;
      };

  home-manager.users."eford" = {
    imports = [
      (
        if config.rv32ima.machine.isRemote then
          "${inputs.self}/modules/home-manager/remote.nix"
        else
          "${inputs.self}/modules/home-manager/local.nix"
      )
    ];

    home.username = "eford";
    home.stateVersion = "25.05";
    home.packages = with pkgs; [
      zigpkgs."0.14.1"
      zls.packages.${system}.default

      duckdb
      google-cloud-sdk
      awscli2
      rclone

      tenv
    ];

  };

}
