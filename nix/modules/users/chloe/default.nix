{
  pkgs,
  options,
  config,
  lib,
  ...
}:
{
  config = {
    sops.secrets."users/chloe/password" = {
      neededForUsers = true;
      sopsFile = ./secrets/password.yaml;
    };

    users.users."chloe" = {
      openssh.authorizedKeys.keys = [
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIGPUAs4RQBUriBrp7rv2cepCve5eIo6uqFfgs7oPqV9Q" # 1Password -> 'Primary SSH key'
        "sk-ssh-ed25519@openssh.com AAAAGnNrLXNzaC1lZDI1NTE5QG9wZW5zc2guY29tAAAAIJtlo9dfoKwUfxp4IabM/9IpBHurAVGGAajY6sCzShmBAAAABHNzaDo= eford@eford-20RW02G" # Pinterest Laptop Yubikey
      ];
      home = "/home/chloe";
      createHome = true;
      extraGroups = [
        "wheel"
        "trusted"
      ];
      hashedPasswordFile = config.sops.secrets."users/chloe/password".path;
    };
  };

}
