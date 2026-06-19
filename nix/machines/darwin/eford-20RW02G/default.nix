{
  self,
  config,
  lib,
  ...
}:
{
  imports = [
    (self.lib.nixosModule "darwin/workstation")
    (self.lib.nixosModule "users/eford")
  ];
  config = {
    rv32ima.machine.workstation.enable = true;

    services.tailscale.enable = lib.mkForce false;

    nix.settings.trusted-users = [
      "${config.system.primaryUser}"
    ];

    nix.settings.trusted-public-keys = [
      "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
    ];

    nix.settings.trusted-substituters = [
      "https://nix-community.cachix.org"
    ];

    nix.settings.max-jobs = 10;
    nix.distributedBuilds = true;

    system.stateVersion = 6;
    system.primaryUser = "eford";
    nixpkgs.hostPlatform = "aarch64-darwin";
  };
}
