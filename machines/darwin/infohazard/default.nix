{
  config,
  inputs,
  ...
}:
let
  pkgsUnstable = import inputs.nixpkgs-unstable {
    system = config.rv32ima.machine.platform;
  };
in
{

  config = {
    rv32ima.machine.enable = true;
    rv32ima.machine.hostName = "infohazard";
    rv32ima.machine.stateVersion = 6;
    rv32ima.machine.primaryUser = "ellie";
    rv32ima.machine.platform = "aarch64-darwin";
    rv32ima.machine.users = [
      "ellie"
    ];
    rv32ima.machine.isRemote = false;
    rv32ima.machine.workstation.enable = true;

    services.tailscale.package = pkgsUnstable.tailscale;

    nix.distributedBuilds = true;
    nix.settings.max-jobs = 10;
    nix.buildMachines = [
      {
        hostName = "artpop";
        system = "x86_64-linux";
        sshUser = "ellie";
        publicHostKey = "c3NoLWVkMjU1MTkgQUFBQUMzTnphQzFsWkRJMU5URTVBQUFBSUx2RE95ZXJzZzJSVFhGRWpEanZoaXkzNTN0cG9mL2Z4cVU2VlcwNzFhYVEK";
        sshKey = "/etc/nix/builder_ed25519";
        maxJobs = 96;
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
