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
  };

  config = lib.mkIf config.rv32ima.machine.enableZfsMirror {
    disko.devices.disk.disk1 = {
      type = "disk";
      device = builtins.elemAt config.rv32ima.machine.zfsMirrorDisks 0;
      content.type = "gpt";
      content.partitions = {
        ESP = {
          size = "500M";
          type = "EF00";
          content = {
            type = "filesystem";
            format = "vfat";
            mountpoint = "/boot1";
            mountOptions = [ "umask=0077" ];
          };
        };
        swap = {
          size = "16G";
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

    disko.devices.disk.disk2 = {
      type = "disk";
      device = builtins.elemAt config.rv32ima.machine.zfsMirrorDisks 1;
      content.type = "gpt";
      content.partitions = {
        ESP = {
          size = "500M";
          type = "EF00";
          content = {
            type = "filesystem";
            format = "vfat";
            mountpoint = "/boot2";
            mountOptions = [ "umask=0077" ];
          };
        };
        swap = {
          size = "16G";
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

    filesystems."/persist".neededForBoot = true;

    boot.loader.grub.enable = true;
    boot.loader.grub.efiSupport = true;
    boot.loader.grub.mirroredBoots = [
      {
        devices = [ "nodev" ];
        path = "/boot1";
      }
      {
        devices = [ "nodev" ];
        path = "/boot2";
      }
    ];
    boot.loader.efi.canTouchEfiVariables = true;

  };
}
