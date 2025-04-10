{
  pkgs,
  lib,
  inputs,
  home-manager,
  ...
}:
{
  config = {
    services.nix-daemon.enable = true;
    system.stateVersion = 5;
    nix.settings.max-jobs = 16;

    programs.gnupg.agent.enable = true;
    programs.gnupg.agent.enableSSHSupport = true;
    services.aerospace = {
      enable = false;
      settings = {
        gaps = {
          outer.left = 8;
          outer.right = 8;
          outer.top = 8;
          outer.bottom = 8;
          inner.horizontal = 8;
          inner.vertical = 8;
        };
        mode.main.binding = {
          cmd-1 = "workspace 1";
          cmd-2 = "workspace 2";
          cmd-3 = "workspace 3";
          cmd-4 = "workspace 4";
          cmd-5 = "workspace 5";
          cmd-6 = "workspace 6";
          cmd-7 = "workspace 7";
          cmd-8 = "workspace 8";
          cmd-9 = "workspace 9";

          cmd-shift-1 = "move-node-to-workspace 1";
          cmd-shift-2 = "move-node-to-workspace 2";
          cmd-shift-3 = "move-node-to-workspace 3";
          cmd-shift-4 = "move-node-to-workspace 4";
          cmd-shift-5 = "move-node-to-workspace 5";
          cmd-shift-6 = "move-node-to-workspace 6";
          cmd-shift-7 = "move-node-to-workspace 7";
          cmd-shift-8 = "move-node-to-workspace 8";
          cmd-shift-9 = "move-node-to-workspace 9";

          cmd-right = "workspace next";
          cmd-left = "workspace prev";
        };
        on-window-detected = [
          {
            "if".app-id = "com.getcleanshot.app-setapp";
            run = [ "layout floating" ];
          }
        ];
      };
    };
    services.jankyborders = {
      enable = true;
      hidpi = true;
    };
    # services.yabai.enable = true;
    # services.yabai.config = {
    #   mouse_follows_focus = "off";
    #   focus_follows_mouse = "on";
    #   window_placement = "second_child";
    #   window_topmost = "off";
    #   window_shadow = "on";
    #   window_opacity = "off";
    #   window_opacity_duration = 0.0;
    #   active_window_opacity = 1.0;
    #   normal_window_opacity = 0.9;
    #   window_border = "off";
    #   window_border_width = 6;
    #   active_window_border_color = "0xff775759";
    #   normal_window_border_color = "0xff555555";
    #   insert_feedback_color = "0xffd75f5f";
    #   split_ratio = 0.5;
    #   auto_balance = "off";
    #   mouse_modifier = "fn";
    #   mouse_action1 = "move";
    #   mouse_action2 = "resize";
    #   mouse_drop_action = "swap";

    #   # general space settings
    #   layout = "bsp";
    #   top_padding = 12;
    #   bottom_padding = 12;
    #   left_padding = 12;
    #   right_padding = 12;
    #   window_gap = 6;
    # };

    # services.yabai.extraConfig = ''
    #   yabai -m rule --add app="^iStat Menus Status$" sticky=on layer=above manage=off
    #   yabai -m rule --add app="Fantastical Helper" border=off manage=off
    #   yabai -m rule --add app="CleanShot X" manage=off mouse_follows_focus=off
    #   yabai -m rule --add app="^CleanShot X$" manage=off
    #   yabai -m rule --add app="ImHex" sticky=on layer=above manage=off
    #   yabai -m rule --add app="Dropshare" sticky=on layer=above manage=off
    #   yabai -m rule --add app="^Arc$" title="^$" mouse_follows_focus=off
    # '';

    users.users.ellie = {
      home = "/Users/ellie";
      shell = pkgs.fish;
    };

    programs.fish.enable = true;
    programs.fish.useBabelfish = true;

    programs.zsh.enable = true;

    # environment.systemPackages = with pkgs; [
    # arc-browser
    # vscode
    # _1password
    # ];

    system.defaults.dock.autohide = true;
    system.defaults.dock.mru-spaces = false;
    system.defaults.dock.show-recents = false;
    system.defaults.finder.AppleShowAllExtensions = true;
    system.defaults.finder.AppleShowAllFiles = true;
  };
}
