{
  config,
  inputs,
  lib,
  self,
  ...
}:
let
  pkgsUnstable = import inputs.nixpkgs-unstable {
    system = config.rv32ima.machine.platform;
  };
in
{
  imports = [
    (self.lib.nixosModule "darwin/workstation")

    (self.lib.userModule "ellie")
  ];

  config = {
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

    nix.linux-builder = {
      enable = true;
      ephemeral = true;
      maxJobs = 10;
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

    system.stateVersion = 6;
    system.primaryUser = "ellie";
    nixpkgs.hostPlatform = "aarch64-darwin";
    networking.hostName = "infohazard";
    networking.domain = "net.ellie.fm";
  };
}
