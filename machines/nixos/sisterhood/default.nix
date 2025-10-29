{
  ...
}:
{
  imports = [
    ./network.nix
    ./disk-config.nix
  ];

  config = {
    rv32ima.machine.enable = true;
    rv32ima.machine.hostName = "sisterhood";
    rv32ima.machine.stateVersion = "25.05";
    rv32ima.machine.platform = "x86_64-linux";
    rv32ima.machine.users = [
      "root"
      "ellie"
    ];
    rv32ima.machine.isRemote = true;
    rv32ima.machine.impermanence.enable = true;
    rv32ima.machine.impermanence.extraPersistDirectories = [
      {
        path = "/var/log";
        mode = "0644";
        owner = "root";
        group = "root";
      }
      {
        path = "/var/lib/nixos";
        mode = "0644";
        owner = "root";
        group = "root";
      }
      {
        path = "/var/lib/systemd/coredump";
        mode = "0644";
        owner = "root";
        group = "root";
      }
      {
        path = "/var/lib/systemd/timers";
        mode = "0644";
        owner = "root";
        group = "root";
      }
      {
        type = "f";
        path = "/var/lib/tailscale/tailscaled.state";
        mode = "0600";
        owner = "root";
        group = "root";
      }
      {
        path = "/var/lib/plex";
        mode = "0644";
        owner = "plex";
        group = "plex";
      }
    ];

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
    boot.kernelModules = [ "kvm-intel" ];
    boot.extraModulePackages = [ ];

    # head -c4 /dev/urandom | od -A none -t x4
    networking.hostId = "a41ae525";

    services.tailscale.enable = true;
    services.tailscale.openFirewall = true;

    services.prometheus.exporters.node.enable = true;

    services.openssh.enable = true;
    services.openssh.openFirewall = false;

    programs.fish.enable = true;
    programs.fish.useBabelfish = true;

    networking.useNetworkd = true;
    networking.firewall.allowedTCPPorts = [ ];
    networking.firewall.logRefusedConnections = false;

    services.plex.enable = true;
    services.plex.openFirewall = true;
  };
}
