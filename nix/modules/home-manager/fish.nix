{ config, ... }: {
  programs.fish.enable = true;
  programs.fish.useBabelfish = true;
  home-manager.users."${config.system.primaryUser}" = { config, ... }: {
    programs.fish = {
      enable = true;
      # TODO: don't do this anymore
      shellInit = ''
        cat ${config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/.dotfiles/fish/init.fish"} | source
      '';
    };
  };
}
