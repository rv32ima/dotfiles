{
  lib,
  vars',
  config,
  inputs,
  ...
}:

# Blatantly stolen from https://codeberg.org/dma/infra/src/branch/main/nixos/modules/gitops.nix
{
  imports = [
    inputs.comin.nixosModules.comin
  ];

  options.gitops = {
    enable = lib.mkEnableOption "GitOps from dma/infra/nixos";

    ref = lib.mkOption {
      type = lib.types.str;
      default = "main";
      description = "Git reference (branch, tag, commit) to use for GitOps.";
    };

    repo = lib.mkOption {
      type = lib.types.str;
      readOnly = true;
      description = "Git repository URL to use for GitOps.";
    };

    subdir = lib.mkOption {
      type = lib.types.str;
      readOnly = true;
      description = "Subdirectory in the Git repository to use for GitOps.";
    };

    interval = lib.mkOption {
      type = lib.types.int;
      default = 10;
      description = "Interval in seconds to check for updates.";
    };

    delay = lib.mkOption {
      type = lib.types.int;
      default = 0;
      description = "Delay in seconds before the deployment is actually applied. This can be used to stagger deployments across multiple machines.";
    };
  };

  config = {
    gitops = {
      repo = "https://github.com/rv32ima/dotfiles.git";
      subdir = "nix";
      ref = "main";
      # This should be enough time to allow Hydra to kick off a build for our machine
      delay = 300;
    };

    services.comin = {
      enable = config.gitops.enable;
      remotes = [
        {
          name = "origin";
          url = config.gitops.repo;
          poller.period = config.gitops.interval;
          branches.main.name = config.gitops.ref;
        }
      ];
      machineId = vars'.machineID;
      # machineId = null;
      repositorySubdir = config.gitops.subdir;
      repositoryType = "flake";
      buildConfirmer = {
        mode = if config.gitops.delay > 0 then "auto" else "without";
        autoconfirm_duration = config.gitops.delay;
      };
    };
  };
}
