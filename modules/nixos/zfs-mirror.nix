{
  inputs,
  config,
  lib,
  ...
}:
{
  imports = [
    inputs.disko.nixosModules.disko
  ];

  options = {
    rv32ima.machine.enableZfsMirror = lib.mkEnableOption "Enable the ZFS mirrored disks option";
    rv32ima.machine.zfsMirrorDisks = lib.mkOption {
      type = lib.types.listOf lib.types.str;
    };
    rv32ima.machine.swapSizePerDisk = lib.mkOption {
      type = lib.types.str;
      default = "16G";
    };
  };

  config = lib.mkIf config.rv32ima.machine.enableZfsMirror {
    disko.devices.disk = builtins.listToAttrs (
      lib.imap (i: disk: {
        name = "disk${i}";
        value = {
          type = "disk";
          device = disk;
          content.type = "gpt";
          content.partitions = {
            ESP = {
              size = "500M";
              type = "EF00";
              content = {
                type = "filesystem";
                format = "vfat";
                mountpoint = "/boot${i}";
                mountOptions = [ "umask=0077" ];
              };
            };
            swap = {
              size = config.rv32ima.machine.swapSizePerDisk;
              content = {
                type = "swap";
                discardPolicy = "both";
              };
            };
            root = {
              size = "100%";
              content = {
                type = "zfs";
                pool = "zroot";
              };
            };
          };
        };
      }) config.rv32ima.machine.zfsMirrorDisks
    );

    disko.devices.zpool.zroot = {
      type = "zpool";
      mode = "mirror";
      options = {
        ashift = "12";
      };
      rootFsOptions = {
        acltype = "posixacl";
        atime = "off";
        compression = "zstd";
        mountpoint = "none";
        xattr = "sa";
        "com.sun:auto-snapshot" = "false";
      };
      datasets = {
        root = {
          type = "zfs_fs";
          mountpoint = "/";
          options.mountpoint = "legacy";
        };
        home = {
          type = "zfs_fs";
          mountpoint = "/home";
          options.mountpoint = "legacy";
        };
        persist = {
          type = "zfs_fs";
          mountpoint = "/persist";
          options.mountpoint = "legacy";
        };
        nix = {
          type = "zfs_fs";
          mountpoint = "/nix";
          options.mountpoint = "legacy";
        };
      };
    };

    fileSystems."/persist".neededForBoot = true;

    boot.loader.grub.enable = true;
    boot.loader.grub.efiSupport = true;
    boot.loader.grub.mirroredBoots = lib.imap (i: _: {
      devices = [ "nodev" ];
      path = "/boot${i}";
    }) config.rv32ima.machine.zfsMirrorDisks;

    boot.loader.efi.canTouchEfiVariables = true;

  };
}
