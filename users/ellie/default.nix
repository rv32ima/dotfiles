{
  pkgs,
  options,
  config,
  inputs,
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
# You might be saying, "ew ellie, yuck!", why do you have to do this hack?
# I know, I know. But dynamic imports based off of an option doesn't work.
lib.mkIf (builtins.elem "ellie" config.rv32ima.machine.users) {
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
      (
        if config.rv32ima.machine.isRemote then
          "${inputs.self}/modules/home-manager/remote.nix"
        else
          "${inputs.self}/modules/home-manager/local.nix"
      )
    ];

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
    ];
  };

}
