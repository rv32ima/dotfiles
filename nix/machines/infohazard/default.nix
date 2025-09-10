{
  ...
}:
{
  config = {
    system.stateVersion = 6;
    nix.settings.max-jobs = 10;
    nix.buildMachines = [
      {
        hostName = "artpop";
        system = "x86_64-linux";
        sshUser = "ellie";
        publicHostKey = "c3NoLWVkMjU1MTkgQUFBQUMzTnphQzFsWkRJMU5URTVBQUFBSUx2RE95ZXJzZzJSVFhGRWpEanZoaXkzNTN0cG9mL2Z4cVU2VlcwNzFhYVE=";
        sshKey = "/etc/nix/builder_ed25519";
        maxJobs = 96;
        protocol = "ssh";
        supportedFeatures = [
          "kvm"
          "benchmark"
          "big-parallel"
        ];
      }
    ];
  };
}
