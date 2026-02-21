{
  pkgs,
  options,
  config,
  lib,
  inputs,
  self,
  ...
}:
let
  homeDirectory =
    user:
    if (lib.hasSuffix "darwin" config.nixpkgs.hostPlatform.config) then
      "/Users/${user}"
    else
      "/home/${user}";

in
{
  programs.fish.enable = true;
  programs.fish.useBabelfish = true;

  users.users."eford" = {
    shell = pkgs.fish;
    home = homeDirectory "eford";
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
      (self.lib.nixosModule "home-manager/local")
    ];

    home.file."bin" = {
      source = "${inputs.self}/bin";
      recursive = true;
    };

    home.sessionPath = [
      "${homeDirectory "eford"}/bin"
    ];

    home.username = "eford";
    home.stateVersion = "25.05";
    home.packages = with pkgs; [
      zigpkgs."0.15.1"
      inputs.zls.packages.${system}.default
      cargo-mommy

      duckdb
      google-cloud-sdk
      awscli2
      rclone

      tenv
      nix-your-shell
    ];
  };

}
