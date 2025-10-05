{
  modulesPath,
  inputs,
  system,
  pkgs,
  lib,
  ...
}:
{
  imports = [
    "${modulesPath}/installer/cd-dvd/installation-cd-minimal.nix"
  ];

  config = {
    environment.systemPackages = [
      inputs.disko.packages.${system}.default
    ];

    networking.hostName = "foundry-receipt-printer";
    networking.domain = "int.devhack.net";
    isoImage.squashfsCompression = "gzip -Xcompression-level 1";
    systemd.services.sshd.wantedBy = lib.mkForce [ "multi-user.target" ];
    users.users.root.openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIGPUAs4RQBUriBrp7rv2cepCve5eIo6uqFfgs7oPqV9Q" # 1Password -> 'Primary SSH key'
    ];

    environment.etc."NetworkManager/system-connections/wifi.nmconnection" = {
      mode = "0400";
      source = pkgs.writeText "wifi.nmconnection" ''
        [connection]
        id=wifi
        type=wifi

        [wifi]
        ssid=wlan0

        [wifi-security]
        key-mgmt=wpa-psk
        psk=/dev/hack
      '';
    };

    networking.networkmanager.enable = true;
    networking.wireless.enable = false;

    networking.firewall.allowedTCPPorts = [
      22
    ];
  };
}
