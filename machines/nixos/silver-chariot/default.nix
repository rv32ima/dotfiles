{
  config,
  inputs,
  self,
  ...
}:
let
  pkgsUnstable = import inputs.nixpkgs-unstable {
    system = config.rv32ima.machine.platform;
  };
in
{
  imports = [
    (self.lib.nixosModule "nixos/impermanence")
    (self.lib.nixosModule "nixos/zfs-mirror")
    (self.lib.nixosModule "nixos/remote-builder")
    (self.lib.nixosModule "users/root")
    (self.lib.nixosModule "users/ellie")

    ./network.nix
  ];

  config = {
    rv32ima.machine.impermanence.enable = true;
    rv32ima.machine.enableZfsMirror = true;
    rv32ima.machine.zfsMirrorDisks = [
      "/dev/disk/by-id/scsi-364cd98f0bbce9400305770c1cebe185d"
      "/dev/disk/by-id/scsi-364cd98f0bbce9400305770c2d0c58853"
    ];
    rv32ima.machine.impermanence.extraPersistDirectories = [
      {
        path = /var/lib/cloudflared;
        mode = "0770";
        owner = "nobody";
        group = "nogroup";
      }
    ];
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
    boot.kernelModules = [ "kvm-intel" ];
    boot.extraModulePackages = [ ];

    # head -c4 /dev/urandom | od -A none -t x4
    networking.hostId = "a76f6c36";

    sops.secrets."services/tailscale/authKey" = {
      sopsFile = ./secrets/tailscale.yaml;
    };

    services.tailscale.enable = true;
    services.tailscale.package = pkgsUnstable.tailscale;
    services.tailscale.openFirewall = true;
    services.tailscale.useRoutingFeatures = "both";
    services.tailscale.authKeyFile = config.sops.secrets."services/tailscale/authKey".path;
    services.tailscale.authKeyParameters.ephemeral = false;
    services.tailscale.authKeyParameters.preauthorized = true;
    services.tailscale.extraUpFlags = [
      "--advertise-tags=tag:infra"
      "--accept-routes"
    ];
    services.tailscale.extraSetFlags = [ "--accept-routes" ];
    networking.firewall.trustedInterfaces = [ "tailscale0" ];

    services.prometheus.exporters.node.enable = true;

    services.openssh.enable = true;
    services.openssh.openFirewall = false;

    programs.fish.enable = true;
    programs.fish.useBabelfish = true;

    networking.useNetworkd = true;
    networking.firewall.allowedTCPPorts = [ ];

    nixpkgs.hostPlatform = "x86_64-linux";
    system.stateVersion = "25.11";
    networking.domain = "sea.t4t.net";
  };
}
