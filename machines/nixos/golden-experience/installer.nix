{
  modulesPath,
  inputs,
  lib,
  ...
}:
{
  imports = [
    "${modulesPath}/installer/netboot/netboot-minimal.nix"
  ];

  config = {
    rv32ima.machine.enable = true;
    rv32ima.machine.hostName = "zephyr";
    rv32ima.machine.stateVersion = "25.05";
    rv32ima.machine.platform = "x86_64-linux";
    rv32ima.machine.users = [
      "root"
    ];
    rv32ima.machine.isRemote = true;

    environment.systemPackages = [
      inputs.disko.packages.x86_64-linux.default
    ];

    # boot.loader.efi.canTouchEfiVariables = true;
    # boot.loader.grub.efiSupport = true;
    # boot.loader.grub.efiInstallAsRemovable = true;
    # boot.loader.grub.device = "nodev";

    # isoImage.squashfsCompression = "gzip -Xcompression-level 1";
    systemd.services.sshd.wantedBy = lib.mkForce [ "multi-user.target" ];

    networking.firewall.allowedTCPPorts = [
      22
    ];
  };
}
