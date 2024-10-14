{ pkgs, lib, inputs, home-manager, ... }: 
{
  config = {
    system.stateVersion = 5;
    nixpkgs.hostPlatform = "aarch64-darwin";
    nix.settings.max-jobs = 24;
    nixpkgs.config.allowUnfree = true;

    programs.gnupg.agent.enable = true;
    programs.gnupg.agent.enableSSHSupport = true;
    services.yabai.enable = true;
    services.yabai.config = {
      mouse_follows_focus = "off";
      focus_follows_mouse = "on";
      window_placement = "second_child";
      window_topmost = "off";
      window_shadow = "on";
      window_opacity = "off";
      window_opacity_duration = 0.0;
      active_window_opacity = 1.0;
      normal_window_opacity = 0.90;
      window_border = "off";
      window_border_width = 6;
      active_window_border_color = "0xff775759";
      normal_window_border_color = "0xff555555";
      insert_feedback_color = "0xffd75f5f";
      split_ratio = 0.50;
      auto_balance = "off";
      mouse_modifier = "fn";
      mouse_action1 = "move";
      mouse_action2 = "resize";
      mouse_drop_action = "swap";

      # general space settings
      layout = "bsp";
      top_padding = 12;
      bottom_padding = 12;
      left_padding = 12;
      right_padding = 12;
      window_gap = 6;
    };

    services.yabai.extraConfig = ''
      yabai -m rule --add app="^iStat Menus Status$" sticky=on layer=above manage=off
      yabai -m rule --add app="Fantastical Helper" border=off manage=off
      yabai -m rule --add app="CleanShot X" manage=off mouse_follows_focus=off
      yabai -m rule --add app="^CleanShot X$" manage=off
      yabai -m rule --add app="ImHex" sticky=on layer=above manage=off
      yabai -m rule --add app="Dropshare" sticky=on layer=above manage=off
      yabai -m rule --add app="^Arc$" title="^$" mouse_follows_focus=off
    '';

    users.users.ellie = {
      home = "/Users/ellie";
      shell = pkgs.fish;
    };

    programs.fish.enable = true;
    programs.fish.useBabelfish = true;

    programs.zsh.enable = true;

    environment.systemPackages = with pkgs; [
      arc-browser
      vscode
      _1password
    ];

    system.defaults.dock.autohide = true; 
    system.defaults.dock.mru-spaces = false;
    system.defaults.dock.show-recents = false;
    system.defaults.finder.AppleShowAllExtensions = true;
    system.defaults.finder.AppleShowAllFiles = true;
  };
}
