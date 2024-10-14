{config, pkgs, lib, ...}: {
  programs.home-manager.enable = true;
  programs.zsh.enable = true;
  programs.fish.enable = true;
  # TODO: don't do this anymore
  programs.fish.shellInit = builtins.readFile ../fish/init.fish;

  home.username = "ellie";
  home.packages = with pkgs; [
    nodejs_18
    go_1_23
    pkgs.rust-bin.stable.latest.default
    eza
    bat
    neovim
    tmux
    gnupg
  ];
  
  home.stateVersion = "24.05";
}