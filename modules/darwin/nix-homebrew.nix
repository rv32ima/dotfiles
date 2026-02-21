{ config, inputs, ... }:
{
  imports = [
    inputs.nix-homebrew.darwinModules.nix-homebrew
  ];

  config = {
    nix-homebrew = {
      autoMigrate = true;
      enable = true;
      enableRosetta = true;
      user = config.system.primaryUser;
      taps = {
        "homebrew/homebrew-core" = inputs.homebrew-core;
        "homebrew/homebrew-cask" = inputs.homebrew-cask;
        "homebrew/homebrew-bundle" = inputs.homebrew-bundle;
        "theseal/homebrew-ssh-askpass" = inputs.darwin-ssh-askpass;
      };
      mutableTaps = false;
    };
  };
}
