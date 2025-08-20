{
  lib,
  pkgs,
  config,
  primaryUser,
  stateVersion,
  ...
}:
{
  config = {
    programs = {
      home-manager.enable = true;
      zsh.enable = true;
      fish = {
        enable = true;
        # TODO: don't do this anymore
        shellInit = builtins.readFile ../../fish/init.fish;
      };

      starship = {
        enable = true;
        # TODO: don't do this anymore
        settings = builtins.fromTOML (builtins.readFile ../../starship.toml);
      };

      git = {
        enable = true;
        extraConfig = builtins.readFile ../../git/${primaryUser}.gitconfig;
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

    home = {
      username = "ellie";
      homeDirectory = lib.mkDefault "/home/ellie";
      packages = with pkgs; [
        nodejs_20
        go_1_23
        git
        (rust-bin.stable.latest.default.override {
          extensions = [ "rust-src" ]; 
        })
        eza
        bat
        gnupg
        sccache
        nil
        nixfmt-rfc-style
        packer
        buf
        graphviz
        bazelisk
        jujutsu
      ];

      stateVersion = "24.05";
    };

    xdg.configFile."nvim/lua" = {
      recursive = true;
      source = ../nvim/lua;
    };
  };
}
