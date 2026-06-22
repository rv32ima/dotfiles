{
  pkgs,
  config,
  ...
}:
{
  home-manager.users."${config.system.primaryUser}" = { config, ... }: {
    home.packages = with pkgs; [
      claude-code
    ];

    home.file.".claude" = {
      enable = true;
      recursive = true;
      source = config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/.dotfiles/claude";
    };
  };
}
