{
  ...
}:
{
  disko.devices.disk.disk1 = {
    type = "disk";
    device = "/dev/disk/by-id/scsi-36f4ee080698bd8002f8844544d27ff18";
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
      zfs = {
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
    device = "/dev/disk/by-id/scsi-36f4ee080698bd8002f88445750a38876";
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
      zfs = {
        size = "100%";
        content = {
          type = "zfs";
          pool = "zroot";
        };
      };
    };
  };

  disko.devices.disk.disk3 = {
    type = "disk";
    device = "/dev/disk/by-id/scsi-36f4ee080698bd8002f884459548fb8ea";
    content.type = "gpt";
    content.partitions = {
      ESP = {
        size = "500M";
        type = "EF00";
        content = {
          type = "filesystem";
          format = "vfat";
          mountpoint = "/boot3";
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
      zfs = {
        size = "100%";
        content = {
          type = "zfs";
          pool = "zroot";
        };
      };
    };
  };

  disko.devices.disk.disk4 = {
    type = "disk";
    device = "/dev/disk/by-id/scsi-36f4ee080698bd8002f88445c58305558";
    content.type = "gpt";
    content.partitions = {
      ESP = {
        size = "500M";
        type = "EF00";
        content = {
          type = "filesystem";
          format = "vfat";
          mountpoint = "/boot4";
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
      zfs = {
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
    mode.topology = {
      type = "topology";
      vdev = [
        {
          mode = "mirror";
          members = [
            "disk1"
            "disk2"
          ];
        }
        {
          mode = "mirror";
          members = [
            "disk3"
            "disk4"
          ];
        }
      ];
    };
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
      media = {
        type = "zfs_fs";
        mountpoint = "/media";
        options.mountpoint = "legacy";
      };
    };
  };

  fileSystems."/persist".neededForBoot = true;

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
    {
      devices = [ "nodev" ];
      path = "/boot3";
    }
    {
      devices = [ "nodev" ];
      path = "/boot4";
    }
  ];

  boot.loader.efi.canTouchEfiVariables = true;
}
