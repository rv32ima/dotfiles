{
  pkgs,
  options,
  config,
  inputs,
  self,
  lib,
  ...
}:
let
  homeDirectory =
    user:
    if (lib.hasSuffix "darwin" config.nixpkgs.hostPlatform.config) then
      "/Users/${user}"
    else
      "/home/${user}";

  canSetPassword = builtins.hasAttr "hashedPasswordFile" (options.users.users.type.getSubOptions { });
in
{
  programs.fish.enable = true;
  programs.fish.useBabelfish = true;

  sops.secrets."users/ellie/password" = lib.mkIf canSetPassword {
    neededForUsers = true;
    sopsFile = ./secrets/password.yaml;
  };

  users.users."ellie" = {
    openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIGPUAs4RQBUriBrp7rv2cepCve5eIo6uqFfgs7oPqV9Q" # 1Password -> 'Primary SSH key'
    ];
    shell = pkgs.fish;
    home = homeDirectory "ellie";
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
      }
  // lib.optionalAttrs canSetPassword {
    hashedPasswordFile = config.sops.secrets."users/ellie/password".path;
  };

  home-manager.users."ellie" = {
    imports = [
      (self.lib.nixosModule "home-manager/local")
    ];

    home.file.".ssh/config" = {
      enable = true;
      recursive = true;
      source = ../../ssh/ellie.config;
    };

    home.file."bin" = {
      source = "${inputs.self}/bin";
      recursive = true;
    };

    home.sessionPath = [
      "${homeDirectory "ellie"}/bin"
    ];

    home.username = "ellie";
    home.stateVersion = "25.05";
    home.packages = with pkgs; [
      p7zip-rar
      age
      sops
      typst
      tinymist
      kubectx
      step-cli
      awscli2
      cargo-mommy
      lixPackageSets.stable.lix
      nix-your-shell
      fluxcd
      doctl
    ];
  };

}
