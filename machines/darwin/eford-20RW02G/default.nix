{
  self,
  config,
  ...
}:
{
  imports = [
    (self.lib.nixosModule "darwin/workstation")
    (self.lib.nixosModule "users/eford-pinterest")
  ];
  config = {
    rv32ima.machine.workstation.enable = true;

    nix.buildMachines = [
      {
        hostName = "golden-experience.home.t4t.net";
        system = "x86_64-linux";
        sshUser = "nix";
        publicHostKey = "c3NoLWVkMjU1MTkgQUFBQUMzTnphQzFsWkRJMU5URTVBQUFBSU1yL2oxQUp4Y2J6aGZzTjJpWjdjUW5Wem1Cc0pINkZjSnh2VDhlRVVvRUwK";
        sshKey = "/etc/nix/builder_ed25519";
        maxJobs = 32;
        protocol = "ssh-ng";
        supportedFeatures = [
          "kvm"
        ];
      }
    ];

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
