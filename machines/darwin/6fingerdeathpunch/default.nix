{
  self,
  ...
}:
{
  imports = [
    (self.lib.nixosModule "darwin/workstation")

    (self.lib.userModule "eford-tvsci")
  ];
  config = {
    rv32ima.machine.workstation.enable = true;

    nix.settings.max-jobs = 10;
    nix.distributedBuilds = true;
    nix.buildMachines = [
      {
        hostName = "44.242.223.63";
        system = "aarch64-linux";
        sshUser = "root";
        publicHostKey = "c3NoLWVkMjU1MTkgQUFBQUMzTnphQzFsWkRJMU5URTVBQUFBSUVxMW4ybjZEeFJ1dU8zS2kxVHJ4Qk9PWFpOZ2ZKaitOWjRqUjFDVy9Cb2EK";
        sshKey = "/etc/nix/builder_ed25519";
        maxJobs = 96;
        protocol = "ssh-ng";
        supportedFeatures = [
          "kvm"
        ];
      }
      {
        hostName = "35.94.33.174";
        system = "x86_64-linux";
        sshUser = "root";
        publicHostKey = "c3NoLWVkMjU1MTkgQUFBQUMzTnphQzFsWkRJMU5URTVBQUFBSUFENlNHMnhJQ2pRMTBMZUMwd3pKaitqb1FtTnZzWmJjamczalUrVU5RaWoK";
        sshKey = "/etc/nix/builder_ed25519";
        maxJobs = 192;
        protocol = "ssh-ng";
        supportedFeatures = [
          "kvm"
        ];
      }
    ];

    system.stateVersion = 6;
    system.primaryUser = "eford";
    nixpkgs.hostPlatform = "aarch64-darwin";
    networking.hostName = "6fingerdeathpunch";
    networking.domain = "net.ellie.fm";
  };
}
