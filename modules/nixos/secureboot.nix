{
  lib,
  pkgs,
  inputs,
  config,
  ...
}:

let
  inherit (inputs) lanzaboote;
in

{
  imports = [
    lanzaboote.nixosModules.lanzaboote
  ];

  services.fwupd.enable = true;

  boot = {
    bootspec.enable = true;
    loader.systemd-boot.enable = lib.mkForce false;
    initrd = {
      systemd = {
        enable = true;
        tpm2.enable = true;
      };
    };
    lanzaboote = {
      enable = true;
      configurationLimit = 15;
      # Fix bug with sbctl. See:
      # https://github.com/nix-community/lanzaboote/issues/413
      pkiBundle = "/var/lib/sbctl";
    };
  };

  security.tpm2 = {
    enable = true;
    pkcs11.enable = true;
    tctiEnvironment.enable = true;
  };

  environment.systemPackages = with pkgs; [
    sbctl
  ];
}
