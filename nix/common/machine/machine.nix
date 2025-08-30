{
  pkgs,
  lib,
  system,
  isRemote,
  primaryUser,
  ...
}: {
  system.primaryUser = "${primaryUser}";
  
  nix = {
    package = pkgs.lix;
    settings = {
      experimental-features = "nix-command flakes";
      trusted-users = [
        "${primaryUser}"
        "nix"
      ];
    };

    buildMachines = lib.mkDefault (
      if system == "aarch64-darwin" then
        [
          {
            hostName = "linux-builder";
            system = "aarch64-linux";
            sshUser = "builder";
            publicHostKey = "c3NoLWVkMjU1MTkgQUFBQUMzTnphQzFsWkRJMU5URTVBQUFBSUpCV2N4Yi9CbGFxdDFhdU90RStGOFFVV3JVb3RpQzVxQkorVXVFV2RWQ2Igcm9vdEBuaXhvcwo=";
            sshKey = "/etc/nix/builder_ed25519";
            maxJobs = 24;
            protocol = "ssh-ng";
            supportedFeatures = [
              "kvm"
              "benchmark"
              "big-parallel"
            ];
          }
        ]
      else
        []
    );

    distributedBuilds = !isRemote;
  };

}