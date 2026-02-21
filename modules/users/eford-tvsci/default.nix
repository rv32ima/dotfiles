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
      (self.lib.nixosModule "home-manager/common")
    ];

    programs.git = {
      enable = true;
      settings = {
        user = {
          email = "eford@tvscientific.com";
          name = "rv32ima";
        };

        "url \"ssh://git@github.com/\"" = {
          insteadOf = "https://github.com/";
        };
      };
    };

    programs.jujutsu = {
      enable = true;
      settings = {
        user = {
          name = "Ellie Ford";
          email = "eford@tvscientific.com";
        };

        ui = {
          merge-editor = "vscode";
        };
      };
    };

    home.file."bin" = {
      source = "${inputs.self}/bin";
      recursive = true;
    };

    home.sessionPath = [
      "${homeDirectory "eford"}/bin"
    ];

    home.username = "eford";
    home.stateVersion = "25.11";
    home.packages = with pkgs; [
      zigpkgs."0.15.1"
      inputs.zls.packages.${system}.default

      duckdb
      google-cloud-sdk
      awscli2
      rclone
    ];
  };

}
