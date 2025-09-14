{
  pkgs,
  machine,
  options,
  lib,
  ...
}:
let
  homeDirectory = if (lib.hasSuffix "darwin" machine.system) then "/Users" else "/home";
in
{
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
      (if machine.isRemote then ../modules/home-manager/remote.nix else ../modules/home-manager/local.nix)
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
