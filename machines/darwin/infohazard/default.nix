{
  config,
  inputs,
  lib,
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

    # Tailscale Split DNS doesn't work with the OSS-built
    # client, like what comes from Nix. Alas, we have to use the "real" version that
    # uses a kernel extension.
    services.tailscale.enable = lib.mkForce false;
    services.tailscale.package = pkgsUnstable.tailscale;
    homebrew = {
      casks = [
        "tailscale-app"
      ];
    };

    nix.distributedBuilds = true;
    nix.settings.max-jobs = 10;
    nix.buildMachines = [
      {
        hostName = "sisterhood";
        system = "x86_64-linux";
        sshUser = "nix";
        publicHostKey = "c3NoLWVkMjU1MTkgQUFBQUMzTnphQzFsWkRJMU5URTVBQUFBSUsvYUIzdTlRVE02azRMbkZOcjkzR2RJdXUxalFNdHZaNThCYm13dldvRGcK";
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
