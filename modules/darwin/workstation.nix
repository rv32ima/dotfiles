{
  lib,
  config,
  ...
}:
{
  options = {
    rv32ima.machine.workstation.enable = lib.mkEnableOption "is this a workstation";
  };

  config = lib.mkIf config.rv32ima.machine.workstation.enable {
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
          {
            "if" = {
              app-id = "com.googlecode.iterm2";
              window-title-regex-substring = "Hotkey Window";
            };
            run = [ "layout floating" ];
          }
        ];

        on-focus-changed = [ ];
        on-focused-monitor-changed = [ ];
      };
    };

    services.jankyborders = {
      enable = false;
      hidpi = true;
    };

    programs.zsh.enable = true;

    homebrew = {
      enable = true;
      global.autoUpdate = false;
      casks = [
        "1password-cli"
      ];
    };

    system.defaults.dock.autohide = true;
    system.defaults.dock.mru-spaces = false;
    system.defaults.dock.show-recents = false;
    system.defaults.finder.AppleShowAllExtensions = true;
    system.defaults.finder.AppleShowAllFiles = true;

    system.defaults.NSGlobalDomain.NSAutomaticCapitalizationEnabled = false;
    system.defaults.NSGlobalDomain.NSAutomaticDashSubstitutionEnabled = false;
    system.defaults.NSGlobalDomain.NSAutomaticInlinePredictionEnabled = false;
    system.defaults.NSGlobalDomain.NSAutomaticPeriodSubstitutionEnabled = false;
    system.defaults.NSGlobalDomain.NSAutomaticQuoteSubstitutionEnabled = false;
    system.defaults.NSGlobalDomain.NSAutomaticSpellingCorrectionEnabled = false;
    system.defaults.NSGlobalDomain.NSDocumentSaveNewDocumentsToCloud = false;

    system.defaults.NSGlobalDomain."com.apple.keyboard.fnState" = true;
    system.defaults.WindowManager.AutoHide = true;
  };
}
