{
  ...
}:
{
  config = {
    rv32ima.machine.enable = true;
    rv32ima.machine.hostName = "6fingerdeathpunch";
    rv32ima.machine.stateVersion = 6;
    rv32ima.machine.primaryUser = "eford";
    rv32ima.machine.platform = "aarch64-darwin";
    rv32ima.machine.users = [
      "eford"
    ];
    rv32ima.machine.isRemote = false;
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
  };
}
