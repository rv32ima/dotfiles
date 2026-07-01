{
  ...
}:
{
  disko.devices.disk.disk1 = {
    type = "disk";
    device = "/dev/disk/by-id/nvme-SPCC_M.2_PCIe_SSD_A20251111N301TB01404";
    content.type = "gpt";
    content.partitions = {
      ESP = {
        size = "500M";
        type = "EF00";
        content = {
          type = "mdraid";
          name = "boot";
        };
      };
      luks-swap = {
        size = "32G";
        content = {
          type = "luks";
          name = "disk1-luks-swap";
          settings = {
            allowDiscards = true;
          };
          content = {
            type = "swap";
            discardPolicy = "both";
          };
        };
      };
      luks-zroot = {
        size = "100%";
        content = {
          type = "luks";
          name = "disk1-luks-zroot";
          settings = {
            allowDiscards = true;
          };
          content = {
            type = "zfs";
            pool = "zroot";
          };
        };
      };
    };
  };

  disko.devices.disk.disk2 = {
    type = "disk";
    device = "/dev/disk/by-id/nvme-SPCC_M.2_PCIe_SSD_MQ35W98904278";
    content.type = "gpt";
    content.partitions = {
      ESP = {
        size = "500M";
        type = "EF00";
        content = {
          type = "mdraid";
          name = "boot";
        };
      };
      luks-swap = {
        size = "32G";
        content = {
          type = "luks";
          name = "disk2-luks-swap";
          settings = {
            allowDiscards = true;
          };
          content = {
            type = "swap";
            discardPolicy = "both";
          };
        };
      };
      luks-zroot = {
        size = "100%";
        content = {
          type = "luks";
          name = "disk2-luks-zroot";
          settings = {
            allowDiscards = true;
          };
          content = {
            type = "zfs";
            pool = "zroot";
          };
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
            "/dev/mapper/disk1-luks-zroot"
            "/dev/mapper/disk2-luks-zroot"
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
    };
  };

  disko.devices.mdadm.boot = {
    type = "mdadm";
    level = 1;
    metadata = "1.0";
    content = {
      type = "filesystem";
      format = "vfat";
      mountpoint = "/boot";
      mountOptions = [ "umask=0077" ];
    };
  };

  fileSystems."/persist".neededForBoot = true;
  boot.loader.efi.canTouchEfiVariables = true;
}
