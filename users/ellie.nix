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

  users.users."ellie" = {
    openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIGPUAs4RQBUriBrp7rv2cepCve5eIo6uqFfgs7oPqV9Q" # 1Password -> 'Primary SSH key'
    ];
    shell = pkgs.fish;
    home = "${homeDirectory}/ellie";
    createHome = true;
  }
  // lib.optionalAttrs (builtins.hasAttr "isNormalUser" options.users.users.ellie) {
    isNormalUser = true;
  };

  users.groups.wheel.members = [
    "ellie"
  ];

  users.groups.trusted.members = [
    "ellie"
  ];

  home-manager.users."ellie" = {
    imports = [
      (if machine.isRemote then ../modules/home-manager/remote.nix else ../modules/home-manager/local.nix)
    ];

    home.username = "ellie";
    home.stateVersion = "25.05";
    home.packages = with pkgs; [
      p7zip-rar
    ];
  };
}
