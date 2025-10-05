{
  config,
  lib,
  ...
}:
lib.mkIf (builtins.elem "root" config.rv32ima.machine.users) {
  sops.secrets."users/root/password" = {
    neededForUsers = true;
    sopsFile = ./secrets/password.yaml;
  };

  users.users."root" = {
    home = "/root";
    createHome = true;
    hashedPasswordFile = config.sops.secrets."users/root/password".path;
  };
}
