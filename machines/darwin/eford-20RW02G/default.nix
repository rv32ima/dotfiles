{
  self,
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
        hostName = "golden-experience.net.ellie.fm";
        system = "x86_64-linux";
        sshUser = "nix";
        publicHostKey = "c3NoLWVkMjU1MTkgQUFBQUMzTnphQzFsWkRJMU5URTVBQUFBSU81RGRTZnozbHFiWHR6elZGV0JDSWhubEdiQnozOUs0eW9BR04vRFdlTHYK";
        sshKey = "/etc/nix/builder_ed25519";
        maxJobs = 32;
        protocol = "ssh-ng";
        supportedFeatures = [
          "kvm"
        ];
      }
    ];

    nix.settings.max-jobs = 10;
    nix.distributedBuilds = true;

    system.stateVersion = 6;
    system.primaryUser = "eford";
    nixpkgs.hostPlatform = "aarch64-darwin";
    networking.hostName = "eford-20RW02G";
  };
}
