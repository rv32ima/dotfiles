{ config, ... }:
{
  homebrew.casks = [
    "ghostty"
  ];

  home-manager.users."${config.system.primaryUser}" = { config, ... }: {
    home.file.".config/ghostty/config" = {
      source = config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/.dotfiles/ghostty/config";
      recursive = true;
    };
  };
}
