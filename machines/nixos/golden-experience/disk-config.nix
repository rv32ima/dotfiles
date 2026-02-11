{
  ...
}:
{
  disko.devices.disk.disk1 = {
    type = "disk";
    device = "/dev/disk/by-id/nvme-Samsung_SSD_990_PRO_4TB_S7KGNJ0Y518139R";
    content.type = "gpt";
    content.partitions = {
      ESP = {
        size = "1G";
        type = "EF00";
        content = {
          type = "filesystem";
          format = "vfat";
          mountpoint = "/boot";
          mountOptions = [ "umask=0077" ];
        };
      };
      swap = {
        size = "128G";
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
  boot.loader.grub.efiInstallAsRemovable = true;
  boot.loader.grub.device = "nodev";
}
