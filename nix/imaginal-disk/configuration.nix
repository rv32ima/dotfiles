{
  config,
  lib,
  pkgs,
  ...
}:

{
  imports = [
    ./hardware.nix
  ];

  boot.supportedFilesystems = [ "zfs" ];
  boot.zfs.extraPools = [ "tank" ];
  services.zfs.autoScrub.enable = true;
  services.zfs.trim.enable = true;

  # Use the systemd-boot EFI boot loader.
  boot.loader.grub = {
    enable = true;
    efiSupport = true;
    device = "/dev/nvme0n1p1";
    efiInstallAsRemovable = true;
  };
  # boot.loader.efi.canTouchEfiVariables = true;

  networking.hostId = "644e57ad";
  networking.hostName = "imaginal-disk";

  time.timeZone = "US/Eastern";

  users.users.ellie = {
    isNormalUser = true;
    extraGroups = [ "wheel" ];
    shell = pkgs.fish;
  };

  users.users.nix = {
    isNormalUser = true;
    openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIBltqZqpO2KCiO4f+rtsHUkOAF9RrJ0+RYTsBrGimDIw root@wallsocket.net.ellie.fm"
    ];
  };

  programs.fish.enable = true;
  environment.systemPackages = with pkgs; [
    htop
    neofetch
    dmidecode
  ];

  services.openssh.enable = true;
  services.vscode-server.enable = true;

  system.stateVersion = "24.05";
}
