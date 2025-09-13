{
  lib,
  pkgs,
  stateVersion,
  primaryUser,
  ...
}:
{
  imports = [
    ./common.nix
  ];

  config = {
    home = {
      file.".ssh" = {
        enable = true;
        recursive = true;
        source = ../../../ssh;
      };

      file.".config/1Password/ssh/agent.toml" = {
        enable = true;
        recursive = true;
        source = ../../../1Password/ssh/agent.${primaryUser}.toml;
      };
    };
  };
}
