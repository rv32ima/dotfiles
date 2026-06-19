{ pkgs, config, ... }: {
  home-manager.users."${config.system.primaryUser}" = { config, ... }: {
    programs.jujutsu = {
      enable = true;
    };

    home.file.".config/jj/conf.d" = {
      source = config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/.dotfiles/jj/conf.d";
      recursive = true;
    };
  };
}
