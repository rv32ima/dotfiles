{
  modulesPath,
  inputs,
  lib,
  ...
}:
{
  imports = [
    "${modulesPath}/installer/cd-dvd/installation-cd-minimal.nix"
    ./network.nix
  ];

  config = {
    rv32ima.machine.enable = true;
    rv32ima.machine.hostName = "unmusique";
    rv32ima.machine.stateVersion = "25.05";
    rv32ima.machine.platform = "x86_64-linux";
    rv32ima.machine.users = [
      "root"
    ];
    rv32ima.machine.isRemote = true;

    environment.systemPackages = [
      inputs.disko.packages.x86_64-linux.default
    ];

    boot.loader.efi.canTouchEfiVariables = true;
    boot.loader.grub.efiSupport = true;
    boot.loader.grub.efiInstallAsRemovable = true;
    boot.loader.grub.device = "nodev";

    isoImage.squashfsCompression = "gzip -Xcompression-level 1";
    systemd.services.sshd.wantedBy = lib.mkForce [ "multi-user.target" ];
    users.users.root.openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIGPUAs4RQBUriBrp7rv2cepCve5eIo6uqFfgs7oPqV9Q" # 1Password -> 'Primary SSH key'
    ];

    networking.firewall.allowedTCPPorts = [
      22
    ];
  };
}
