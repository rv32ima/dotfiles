{
  inputs,
  pkgs,
  self,
  ...
}:
let
  pkgsUnstable = import inputs.nixpkgs-unstable {
    system = pkgs.stdenv.hostPlatform.system;
  };
in
{
  imports = [
    (self.lib.nixosModule "nixos/impermanence")
    (self.lib.nixosModule "nixos/remote-builder")
    # (self.lib.nixosModule "nixos/secureboot")

    (self.lib.nixosModule "users/root")
    (self.lib.nixosModule "users/ellie")

    ./network.nix
    ./disk-config.nix
  ];

  config = {
    rv32ima.machine.impermanence.enable = true;
    rv32ima.machine.impermanence.extraPersistDirectories = [
      {
        path = /var/lib/sbctl;
        mode = "0644";
        owner = "root";
        group = "root";
      }
    ];

    boot.loader.limine.enable = true;
    boot.loader.limine.secureBoot.enable = true;
    boot.loader.limine.efiInstallAsRemovable = true;

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
    services.tailscale.package = pkgsUnstable.tailscale;
    services.tailscale.openFirewall = true;
    services.tailscale.useRoutingFeatures = "both";
    services.tailscale.extraSetFlags = [ "--accept-routes" ];
    networking.firewall.trustedInterfaces = [ "tailscale0" ];

    services.prometheus.exporters.node.enable = true;

    services.openssh.enable = true;
    services.openssh.openFirewall = true;

    programs.fish.enable = true;
    programs.fish.useBabelfish = true;

    networking.useNetworkd = true;
    networking.firewall.allowedTCPPorts = [ ];
    networking.firewall.logRefusedConnections = false;

    networking.domain = "sea.t4t.net";
  };
}
