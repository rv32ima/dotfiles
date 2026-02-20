{
  self,
  ...
}:
{
  imports = [
    (self.lib.user "eford-pinterest")
  ];
  config = {
    rv32ima.machine.enable = true;
    rv32ima.machine.hostName = "eford-20RW02G";
    rv32ima.machine.stateVersion = 6;
    rv32ima.machine.primaryUser = "eford";
    rv32ima.machine.platform = "aarch64-darwin";
    rv32ima.machine.isRemote = false;
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
  };
}
