{
  pkgs,
  ...
}:
let
  sshCA = pkgs.writeText "ssh-ca.pub" ''
    ecdsa-sha2-nistp256 AAAAE2VjZHNhLXNoYTItbmlzdHAyNTYAAAAIbmlzdHAyNTYAAABBBNR6/2huKK07d3kY9NY+zxMdcxhw8Z0gdUyyJcJcyLgPjcOzfAw3QSzndMeZOBGUo7CqQwoc8ZVnKhPiTSFiEL4=
  '';
in
{
  imports = [
    ./network.nix
  ];

  config = {
    rv32ima.machine.enable = true;
    rv32ima.machine.hostName = "fadeoutz";
    rv32ima.machine.stateVersion = "25.11";
    rv32ima.machine.platform = "x86_64-linux";
    rv32ima.machine.users = [
      "root"
      "ellie"
    ];
    rv32ima.machine.isRemote = true;
    rv32ima.machine.impermanence.enable = true;
    rv32ima.machine.enableZfsMirror = true;
    rv32ima.machine.zfsMirrorDisks = [
      "/dev/disk/by-id/scsi-364cd98f0bbd0f40030574fa2831b8ed7"
      "/dev/disk/by-id/scsi-364cd98f0bbd0f40030574fa3852291f2"
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

    networking.hostId = "669097ce";

    services.tailscale.enable = true;
    services.tailscale.openFirewall = true;

    services.prometheus.exporters.node.enable = true;

    services.openssh.enable = true;
    services.openssh.openFirewall = false;
    services.openssh.extraConfig = ''
      TrustedUserCAKeys ${sshCA}
    '';

    programs.fish.enable = true;
    programs.fish.useBabelfish = true;

    networking.firewall.allowedTCPPorts = [
      80
      443
      8000
    ];
  };
}
