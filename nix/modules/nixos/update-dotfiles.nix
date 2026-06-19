{ pkgs, config, ... }: {
  config = {
    systemd.timers."update-dotfiles" = {
      wantedBy = [ "timers.target" ];
      timerConfig = {
        OnBootSec = "1m";
        OnUnitActiveSec = "1m";
        Unit = "update-dotfiles.service";
      };
    };

    systemd.services."update-dotfiles" = {
      script = ''
        set -eu
        DOTFILES_DIR="${config.users.users."ellie".home}/.dotfiles"
        if [ ! -d "$DOTFILES_DIR" ]; then
          git clone --depth=1 https://github.com/rv32ima/dotfiles.git $DOTFILES_DIR 
        fi
        pushd $DOTFILES_DIR
        git fetch --all
        git reset --hard origin/master
      '';
      environment = {
        GIT_CONFIG_GLOBAL = "/dev/null";
      };
      path = [
        pkgs.git
      ];
      serviceConfig = {
        Type = "oneshot";
        User = "ellie";
      };
      requires = [
        "network.target"
        "network-online.target"
      ];
      after = [
        "network.target"
        "network-online.target"
      ];
    };
  };
}
