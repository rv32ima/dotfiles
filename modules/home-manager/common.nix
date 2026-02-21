{
  pkgs,
  config,
  inputs,
  ...
}:
{
  programs = {
    home-manager.enable = true;
    zsh.enable = true;
    fish = {
      enable = true;
      # TODO: don't do this anymore
      shellInit = builtins.readFile "${inputs.self}/fish/init.fish";
    };

    starship = {
      enable = true;
      # TODO: don't do this anymore
      settings = builtins.fromTOML (builtins.readFile "${inputs.self}/starship/starship.toml");
    };

    git = {
      enable = true;
      settings = {
        user = {
          email = "me@ellie.fm";
          name = "ellie-idb";
        };

        "includeIf \"gitdir:~/work\"" = {
          path = "~/work/.gitconfig";
        };

        http = {
          cookiefile = "~/.gitcookies";
        };

        "url \"ssh://git@github.com/\"" = {
          insteadOf = "https://github.com/";
        };
      };
    };

    jujutsu = {
      enable = true;
      settings = builtins.fromTOML (builtins.readFile "${inputs.self}/jj/${config.home.username}.toml");
    };

    direnv = {
      enable = true;
    };

    tmux = {
      enable = true;
      baseIndex = 1;
      newSession = true;
      shell = "${pkgs.fish}/bin/fish";
      historyLimit = 100000;
      plugins = with pkgs; [
        tmuxPlugins.better-mouse-mode
      ];
    };

    neovim = {
      enable = true;
      vimAlias = true;
      vimdiffAlias = true;
      withNodeJs = true;
      extraLuaConfig = ''
        -- Enable Lua syntax highlighting in the initialization files
        vim.api.nvim_set_var("vimsyn_embed", "l")

        -- Some basic defaults that I like
        vim.g.mapleader = " "
        vim.g.maplocalleader = "\\"
        vim.o.softtabstop = 2
        vim.o.tabstop = 2
        vim.o.shiftwidth = 2
        vim.o.expandtab = true
        vim.o.smartindent = true
        vim.o.autoindent = true
        vim.o.encoding = "utf-8"
        vim.wo.cursorline = true

        -- No clue why we have to go through nvim_exec for these
        vim.cmd("syntax on")
        vim.cmd("filetype plugin on")
      '';
    };
  };

  xdg.configFile."nvim/lua" = {
    recursive = true;
    source = "${inputs.self}/nvim/lua";
  };

  home.packages = with pkgs; [
    # Programming Languages
    nodejs_20
    go_latest
    # (rust-bin.stable.latest.default.override {
    #   extensions = [ "rust-src" ];
    # })

    nixd
    git
    eza
    bat
    gnupg
    diffedit3
    sccache
    nixfmt-rfc-style
    packer
    buf
    graphviz
    bazelisk
    jujutsu
  ];
}
