{
  config,
  inputs,
  ...
}:
let
  pkgsUnstable = import inputs.nixpkgs-unstable {
    system = config.rv32ima.machine.platform;
  };
in
{
  imports = [
    ./disk-config.nix
  ];

  config = {
    rv32ima.machine.enable = true;
    rv32ima.machine.hostName = "golden-experience";
    rv32ima.machine.stateVersion = "25.11";
    rv32ima.machine.platform = "x86_64-linux";
    rv32ima.machine.users = [
      "root"
      "ellie"
    ];
    rv32ima.machine.isRemote = true;
    rv32ima.machine.impermanence.enable = true;
    rv32ima.machine.remote-builder.enable = true;

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
    boot.kernelModules = [ "kvm_amd" ];
    boot.extraModulePackages = [ ];

    # head -c4 /dev/urandom | od -A none -t x4
    networking.hostId = "657c30f3";

    services.tailscale.enable = true;
    services.tailscale.package = pkgsUnstable.tailscale;
    services.tailscale.openFirewall = true;
    services.tailscale.useRoutingFeatures = "both";
    services.tailscale.extraSetFlags = [ "--accept-routes" ];
    networking.firewall.trustedInterfaces = [ "tailscale0" ];

    services.prometheus.exporters.node.enable = true;

    services.openssh.enable = true;
    services.openssh.openFirewall = false;

    programs.fish.enable = true;
    programs.fish.useBabelfish = true;

    networking.useNetworkd = true;
    networking.firewall.allowedTCPPorts = [ ];

    hardware.enableRedistributableFirmware = true;
    hardware.graphics.enable = true;
    hardware.graphics.enable32Bit = true;

    services.ollama.enable = true;
    services.ollama.package = pkgsUnstable.ollama-vulkan;
  };
}
