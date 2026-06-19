# Set of sanity-keeping configurations.
# All machines should import this module.

{
  self,
  pkgs,
  inputs,
  config,
  ...
}:

{
  imports = [
    inputs.sops-nix.darwinModules.sops
    (self.lib.nixosModule "shared/nix-config")
    (self.lib.nixosModule "shared/nixpkgs")
    (self.lib.nixosModule "darwin/home-manager")
    (self.lib.nixosModule "darwin/nix-homebrew")
  ];

  nix.settings.trusted-users = [
    "${config.system.primaryUser}"
  ];

  # Useful tools.
  environment.systemPackages = with pkgs; [
    htop
    jq
    vim
    wget
    # persistent terminal sessions for ssh
    tmux
  ];

  nixpkgs.overlays = builtins.attrValues self.overlays;

  # Where we are roughly:
  time.timeZone = "America/Los_Angeles";
}
