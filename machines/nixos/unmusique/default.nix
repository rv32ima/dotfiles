{
  config,
  ...
}:
{
  imports = [
    ./network.nix
  ];

  config = {
    rv32ima.machine.enable = true;
    rv32ima.machine.hostName = "unmusique";
    rv32ima.machine.stateVersion = "25.05";
    rv32ima.machine.platform = "x86_64-linux";
    rv32ima.machine.users = [
      "root"
      "ellie"
    ];
    rv32ima.machine.isRemote = true;
    rv32ima.machine.impermanence.enable = true;
    rv32ima.machine.enableZfsMirror = true;
    rv32ima.machine.zfsMirrorDisks = [
      "/dev/disk/by-id/ata-MK000480GZXRA_S6M8NE0RC00250"
      "/dev/disk/by-id/ata-MK000480GZXRA_S6M8NE0T100628"
    ];
    rv32ima.machine.impermanence.extraPersistDirectories = [
      {
        path = /var/lib/victoriametrics;
        mode = "0777";
        owner = "root";
        group = "root";
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
      "hpsa"
    ];
    boot.initrd.kernelModules = [ ];
    boot.kernelModules = [ "kvm-intel" ];
    boot.extraModulePackages = [ ];

    networking.hostId = "b89ce780";

    services.tailscale.enable = true;
    services.tailscale.openFirewall = true;

    services.prometheus.exporters.node.enable = true;

    services.openssh.enable = true;
    services.openssh.openFirewall = false;

    programs.fish.enable = true;
    programs.fish.useBabelfish = true;

    networking.useNetworkd = true;
    networking.firewall.allowedTCPPorts = [ ];

    services.victoriametrics.enable = true;
    services.victoriametrics.retentionPeriod = "30d";

    sops.secrets."services/tailscalesd/environment" = {
      sopsFile = ./secrets/tailscalesd.yaml;
    };

    virtualisation.oci-containers.containers."tailscalesd" = {
      image = "ghcr.io/cfunkhouser/tailscalesd:latest";
      hostname = "tailscalesd";
      ports = [ "127.0.0.1:9242:9242" ];
      environmentFiles = [
        config.sops.secrets."services/tailscalesd/environment".path
      ];
    };
  };
}
