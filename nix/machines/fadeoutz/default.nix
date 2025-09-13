{
  nixpkgs,
  disko,
  pkgs,
  ...
}:
let
  lib = nixpkgs.lib;
in
{
  imports = [
    disko.nixosModules.disko
  ];

  config = {
    nix.settings = {
      tarball-ttl = 0;
    };

    boot = {
      loader.grub.enable = true;
      loader.grub.efiSupport = true;
      loader.grub.mirroredBoots = [
        {
          devices = [ "nodev" ];
          path = "/boot1";
        }
        {
          devices = [ "nodev" ];
          path = "/boot2";
        }
      ];
      loader.efi.canTouchEfiVariables = true;
      initrd.availableKernelModules = [
        "ahci"
        "xhci_pci"
        "megaraid_sas"
        "usbhid"
        "usb_storage"
        "sd_mod"
        "sr_mod"
      ];
      initrd.kernelModules = [ ];
      kernelModules = [ "kvm-intel" ];
      extraModulePackages = [ ];
    };

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
        options.cachefile = "none";
        rootFsOptions = {
          compression = "zstd";
          "com.sun:auto-snapshot" = "false";
        };
        mountpoint = "/";
      };
    };

    networking.hostId = "669097ce";
    networking.hostName = "fadeoutz";
    networking.useDHCP = lib.mkDefault false;

    systemd.network.networks.ethernet = {
      enable = true;
      matchConfig = {
        Name = "eno1np0";
      };

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

    services.openssh.enable = true;

    users.users."ellie" = {
      openssh.authorizedKeys.keys = [
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIGPUAs4RQBUriBrp7rv2cepCve5eIo6uqFfgs7oPqV9Q" # 1Password -> 'Primary SSH key'
      ];
      isNormalUser = true;
      group = "wheel";
      shell = pkgs.fish;
      createHome = true;
    };

    networking.useNetworkd = true;
    networking.firewall.allowedTCPPorts = [
      22
    ];
  };
}
