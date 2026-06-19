{ config, ... }:
{
  home-manager.users."${config.system.primaryUser}" = { config, ... }: {
    home.file.".config/ghostty" = {
      source = config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/.dotfiles/ghostty";
      recursive = true;
    };
  };
}
