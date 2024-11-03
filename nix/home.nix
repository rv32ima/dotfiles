{
  lib,
  pkgs,
  user,
  stateVersion,
  ...
}:
{
  programs = {
    home-manager.enable = true;
    zsh.enable = true;
    fish = {
      enable = true;
      # TODO: don't do this anymore
      shellInit = builtins.readFile ../fish/init.fish;
    };
    starship = {
      enable = true;
      # TODO: don't do this anymore
      settings = builtins.fromTOML (builtins.readFile ../starship.toml);
    };
  };

  home = {
    username = "${user}";
    homeDirectory = lib.mkDefault "/home/${user}";
    packages = with pkgs; [
      nodejs_18
      go_1_23
      git
      # pkgs.rust-bin.stable.latest.default
      (pkgs.rust-bin.nightly."2024-07-21".default.override {
        extensions = [ "rust-src" ];
      })
      eza
      bat
      neovim
      tmux
      gnupg
      sccache
      nil
      nixfmt-rfc-style
      packer
      buf
      graphviz
      bazelisk
    ];

    stateVersion = "${stateVersion}";
  };
}
