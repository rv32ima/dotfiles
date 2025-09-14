{
  config,
  lib,
  pkgs,
  ...
}:
let
  nix-ssh-wrapper = pkgs.writeShellScript "nix-ssh-wrapper" ''
    case $SSH_ORIGINAL_COMMAND in
      "nix-daemon --stdio")
        exec ${config.nix.package}/bin/nix-daemon --stdio
        ;;
      "nix-store --serve --write")
        exec ${config.nix.package}/bin/nix-store --serve --write
        ;;
      *)
        echo "Access only allowed for using the nix remote builder" 1>&2
        exit
    esac
  '';
in
{
  options.nix.remote-builder.key = lib.mkOption {
    type = lib.types.singleLineStr;
    default = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIP7LMYuJpon+g+BLC95GIbzt9k0AJcEeIsHLC3rxvii3 builder@localhost";
    description = "ssh public key for the remote build user";
  };

  config.users.users.nix.openssh.authorizedKeys.keys = [
    # use nix-store for hydra which doesn't support ssh-ng
    ''restrict,command="${nix-ssh-wrapper}" ${config.nix.remote-builder.key}''
  ];

  config.nix.settings.trusted-users = [ "nix" ];

  config.users.users.nix = {
    isNormalUser = true;
    group = "nix";
    home = "/var/lib/nix";
    createHome = true;
  };

  config.users.groups.nix = { };
}
