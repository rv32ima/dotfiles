{ config, lib, pkgs, ... }:

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
  };

  environment.systemPackages = with pkgs; [
    htop
    neofetch
  ];

  services.openssh.enable = true;

  system.stateVersion = "24.05";
}