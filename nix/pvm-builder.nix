{ pkgs, lib, modulesPath, ... }: 
{
  imports = ["${modulesPath}/virtualisation/amazon-image.nix"];

  config = {
    programs.fish.enable = true;

    users.users."ellie" = {
      isNormalUser = true;
      group = "wheel";
      shell = pkgs.fish;
      createHome = true;
    };
  }; 
}