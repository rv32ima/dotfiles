{
  inputs,
  pkgs,
  config,
  ...
}:
let
  lib = inputs.nixpkgs.lib;
in
{
  imports = [
    inputs.microvm.nixosModules.host
  ];

  rv32ima.machine.hostName = "fadeoutz";
  rv32ima.machine.stateVersion = "25.05";
  rv32ima.machine.system = "x86_64-linux";
  rv32ima.machine.users = [
    "root"
    "ellie"
  ];
  rv32ima.machine.isRemote = true;

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

  sops.secrets.root_passwd = {
    neededForUsers = true;
    sopsFile = ./secrets/user_passwords.yaml;
  };
  users.users.root.hashedPasswordFile = config.sops.secrets.root_passwd.path;

  programs.fish.enable = true;
  programs.fish.useBabelfish = true;

  networking.useNetworkd = true;
  networking.firewall.allowedTCPPorts = [ ];

  microvm.host.enable = true;
  microvm.vms.tuwunel.config =
    let
      hash = builtins.hashString "sha256" "tuwunel";
      c = off: builtins.substring off 2 hash;
      mac = "${builtins.substring 0 1 hash}2:${c 2}:${c 4}:${c 6}:${c 8}:${c 10}";
    in
    {
      system.stateVersion = lib.trivial.release;
      networking.hostName = "tuwunel";
      microvm = {
        hypervisor = "cloud-hypervisor";
        mem = 4096;
        vcpu = 2;
        interfaces =

          [
            {
              inherit mac;
              type = "tap";
              id = "vm-tuwunel";
            }
          ];

        shares = [
          {
            proto = "virtiofs";
            tag = "ro-store";
            source = "/nix/store";
            mountPoint = "/nix/.ro-store";
          }
        ];
      };

      systemd.network.enable = true;
      systemd.network.networks."01-ethernet" = {
        matchConfig.PermanentMACAddress = mac;
        DHCP = "yes";
      };

      users.users.root.password = "toor";
      services.openssh = {
        enable = true;
        settings.PermitRootLogin = "yes";
      };
    };

  systemd.network.netdevs.virbr0.netdevConfig = {
    Kind = "bridge";
    Name = "virbr0";
  };

  systemd.network.networks.virbr0 = {
    matchConfig.Name = "virbr0";
    addresses = [
      {
        Address = "10.0.0.1/24";
      }
    ];

    networkConfig = {
      DHCPServer = true;
    };
  };

  systemd.network.networks.microvm = {
    matchConfig.Name = "vm-*";
    networkConfig.Bridge = "virbr0";
  };
  networking.firewall.interfaces.virbr0.allowedUDPPorts = [ 67 ];

  networking.nat.enable = true;
  networking.nat.enableIPv6 = true;
  networking.nat.internalInterfaces = [ "virbr0" ];
}
