{
  pkgs,
  config,
  ...
}:
{
  imports = [
    ./network.nix
    ./disk-config.nix
  ];

  config = {
    rv32ima.machine.enable = true;
    rv32ima.machine.hostName = "ghostholding";
    rv32ima.machine.stateVersion = "25.05";
    rv32ima.machine.platform = "x86_64-linux";
    rv32ima.machine.users = [
      "root"
    ];
    rv32ima.machine.isRemote = true;
    rv32ima.machine.impermanence.enable = true;

    services.getty.autologinUser = "root";

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
    boot.kernelModules = [
      "kvm-intel"
      "mlxfw"
    ];
    boot.kernelParams = [
      "console=tty0"
      "console=ttyS0,115200"
      "net.ifnames=0"
      "biosdevname=0"
    ];
    boot.kernelPatches = [
      {
        name = "mlx-stuff";
        patch = null;
        extraConfig = ''
          MELLANOX_PLATFORM y
          MLXREG_HOTPLUG m
          MLXREG_IO m
          MLXREG_LC m
          NVSW_SN2201 m
          SENSORS_MLXREG_FAN m
        '';
      }
    ];
    boot.blacklistedKernelModules = [
      "i2c_mux_reg"
    ];

    hardware.enableAllFirmware = true;

    networking.hostId = "35a29483";

    services.udev.extraRules = ''
      SUBSYSTEM=="net", ACTION=="add", DRIVERS=="mlxsw_spectrum*", NAME="sw$attr{phys_port_name}"
    '';

    boot.kernel.sysctl = {
      "net.ipv4.ip_forward" = "1";
      "net.ipv6.conf.all.forwarding" = "1";
      "net.ipv6.conf.default.forwarding" = "1";
      "net.ipv6.conf.all.keep_addr_on_down" = "1";
      "net.ipv6.conf.default.keep_addr_on_down" = "1";
      "net.ipv4.conf.all.ignore_routes_with_linkdown" = "1";
      "net.ipv6.conf.all.ignore_routes_with_linkdown" = "1";
      "net.ipv4.conf.default.ignore_routes_with_linkdown" = "1";
      "net.ipv6.conf.default.ignore_routes_with_linkdown" = "1";
      "net.ipv4.fib_multipath_hash_policy" = "1";
      "net.ipv6.fib_multipath_hash_policy" = "1";
      "net.ipv6.conf.all.ndisc_notify" = "1";
      "net.ipv6.conf.default.ndisc_notify" = "1";
      "net.ipv4.conf.all.rp_filter" = "0";
      "net.ipv4.conf.default.rp_filter" = "0";
      "net.ipv4.ip_forward_update_priority" = "0";
      "net.ipv6.route.skip_notify_on_dev_down" = "1";
      "net.ipv4.fib_multipath_use_neigh" = "1";
      "net.ipv6.route.max_size" = "16384";
      "net.ipv4.neigh.default.gc_thresh2" = "8192";
      "net.ipv6.neigh.default.gc_thresh2" = "8192";
      "net.ipv4.neigh.default.gc_thresh3" = "8192";
      "net.ipv6.neigh.default.gc_thresh3" = "8192";
    };

    services.tailscale.enable = false;
    services.tailscale.openFirewall = false;

    services.openssh.enable = true;
    services.openssh.openFirewall = true;

    programs.fish.enable = true;
    programs.fish.useBabelfish = true;

    users.users.root.openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIGPUAs4RQBUriBrp7rv2cepCve5eIo6uqFfgs7oPqV9Q" # 1Password -> 'Primary SSH key'
    ];
  };
}
