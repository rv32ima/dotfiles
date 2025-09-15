{
  inputs,
  pkgs,
  ...
}:
let
  lib = inputs.nixpkgs.lib;
in
{
  imports = [
    inputs.disko.nixosModules.disko
    "${inputs.self}/modules/nixos/default.nix"
    "${inputs.self}/modules/nixos/remote-builder.nix"
  ];

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
  boot.initrd.availableKernelModules = [
    "ahci"
    "xhci_pci"
    "megaraid_sas"
    "usbhid"
    "usb_storage"
    "sd_mod"
    "sr_mod"
  ];
  boot.initrd.kernelModules = [ ];
  boot.kernelModules = [ "kvm-intel" ];
  boot.extraModulePackages = [ ];

  disko.devices = {
    disk.disk1 = {
      type = "disk";
      device = "/dev/disk/by-id/scsi-364cd98f0bbd0f40030574fa2831b8ed7";
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

    disk.disk2 = {
      type = "disk";
      device = "/dev/disk/by-id/scsi-364cd98f0bbd0f40030574fa3852291f2";
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

    zpool.zroot = {
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
  };

  boot.initrd.systemd.services.zfs-rollback = {
    enable = true;
    after = [
      "zfs-import-zroot.service"
    ];
    wantedBy = [
      "initrd.target"
    ];
    before = [
      "sysroot.mount"
    ];
    unitConfig.DefaultDependencies = "no";
    serviceConfig.Type = "oneshot";
    script = ''
      ${pkgs.zfs} rollback -r zroot/root@blank && echo "zfs rollback complete"
    '';
  };

  networking.hostId = "669097ce";
  networking.hostName = "fadeoutz";
  networking.useDHCP = lib.mkDefault false;

  systemd.network.networks."01-ethernet" = {
    enable = true;
    matchConfig.PermanentMACAddress = "B0:26:28:C2:C7:20";

    dns = [
      "1.1.1.1"
      "1.0.0.1"
    ];

    routes = [
      {
        Gateway = "108.62.157.254";
      }
    ];

    addresses = [
      {
        Address = "108.62.157.229/27";
      }
    ];
  };

  services.tailscale.enable = true;
  services.tailscale.openFirewall = true;

  services.prometheus.exporters.node.enable = true;

  services.openssh.enable = true;
  services.openssh.openFirewall = false;
  services.openssh.hostKeys = [
    {
      path = "/persist/etc/ssh/ssh_host_ed25519_key";
      type = "ed25519";
    }
    {
      path = "/persist/etc/ssh/ssh_host_rsa_key";
      type = "rsa";
      bits = 4096;
    }
  ];

  systemd.tmpfiles.rules = [
    "d /persist/etc/ssh 0644 root root"
    "d /persist/var/lib 0644 root root"
    "L /var/lib - - - - /persist/var/lib"
  ];

  users.users.root.hashedPassword = "$y$j9T$AzqHjpKC7ASuqPl2pSKiC.$PxcdFS64lUJlsu4ogapeSbi/W9OMQK7qTNLBL8WPoeA";

  programs.fish.enable = true;
  programs.fish.useBabelfish = true;

  networking.useNetworkd = true;
  networking.firewall.allowedTCPPorts = [ 22 ];
}
