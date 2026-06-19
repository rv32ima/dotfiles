{
  config,
  pkgs,
  lib,
  ...
}:
{
  home-manager.users."${config.system.primaryUser}" = { config, ... }: {
    programs.ghostty = {
      enable = true;
      package = lib.mkIf pkgs.stdenv.isDarwin pkgs.ghostty-bin;
    };

    home.file.".config/ghostty" = {
      source = config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/.dotfiles/ghostty";
      recursive = true;
    };
  };
}
