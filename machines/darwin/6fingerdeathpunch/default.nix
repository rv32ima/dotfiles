{
  ...
}:
{
  config = {
    rv32ima.machine.hostName = "6fingerdeathpunch";
    rv32ima.machine.stateVersion = 6;
    rv32ima.machine.primaryUser = "eford";
    rv32ima.machine.platform = "aarch64-darwin";
    rv32ima.machine.users = [
      "eford"
    ];
    rv32ima.machine.isRemote = false;

    nix.settings.max-jobs = 10;
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
        hostName = "54.191.5.245";
        system = "x86_64-linux";
        sshUser = "root";
        publicHostKey = "c3NoLWVkMjU1MTkgQUFBQUMzTnphQzFsWkRJMU5URTVBQUFBSUFWRUNPS3dGY3l3Q0lXTUZQcDZIUVRNVEMwUFVSWUtxZndNVTFEdGZYUkUK";
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
