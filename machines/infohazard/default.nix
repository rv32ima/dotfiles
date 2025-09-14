{
  inputs,
  ...
}:
{
  imports = [
    "${inputs.self}/modules/darwin/workstation.nix"
  ];

  config = {
    nix.settings.max-jobs = 10;
    nix.buildMachines = [
      {
        hostName = "fadeoutz";
        system = "x86_64-linux";
        sshUser = "nix";
        publicHostKey = "c3NoLWVkMjU1MTkgQUFBQUMzTnphQzFsWkRJMU5URTVBQUFBSVAvSkNYMTlaSkpjQTNmTmhXaXdEd1ltZ3R4L3gwWlFtS1RaUGFMM1ZPNmY=";
        sshKey = "/etc/nix/builder_ed25519";
        maxJobs = 48;
        protocol = "ssh-ng";
        supportedFeatures = [
          "kvm"
          "benchmark"
          "big-parallel"
        ];
      }
    ];
  };
}
