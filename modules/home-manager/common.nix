{
  pkgs,
  config,
  inputs,
  ...
}:
{
  home-manager.users."${config.system.primaryUser}" = { config, ... }: {
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
    };

    home.packages = with pkgs; [
      # Programming Languages
      nodejs_latest
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
      cargo-mommy
      tenv
      nix-your-shell
    ];

    home.file.".config/1Password/ssh/agent.toml" = {
      enable = true;
      recursive = true;
      source = config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/.dotfiles/1Password/ssh/agent.${config.home.username}.toml";
    };
  };
}
