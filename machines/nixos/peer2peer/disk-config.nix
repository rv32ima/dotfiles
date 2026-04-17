{
  ...
}:
{
  disko.devices.disk.disk1 = {
    type = "disk";
    device = "/dev/disk/by-id/nvme-Samsung_SSD_990_EVO_Plus_4TB_S7U8NJ0Y627541Z";
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
        size = "32G";
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
    device = "/dev/disk/by-id/nvme-Samsung_SSD_990_EVO_Plus_4TB_S7U8NJ0Y627545L";
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
        size = "32G";
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
  boot.loader.efi.canTouchEfiVariables = true;
}
