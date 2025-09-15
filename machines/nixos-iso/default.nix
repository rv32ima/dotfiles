{
  nixpkgs,
  modulesPath,
  lib,
  ...
}:
{
  imports = [
    "${modulesPath}/installer/cd-dvd/installation-cd-minimal.nix"
  ];

  config = {
    isoImage.squashfsCompression = "gzip -Xcompression-level 1";
    systemd.services.sshd.wantedBy = lib.mkForce [ "multi-user.target" ];
    users.users.root.openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIGPUAs4RQBUriBrp7rv2cepCve5eIo6uqFfgs7oPqV9Q" # 1Password -> 'Primary SSH key'
    ];

    systemd.network.networks."01-ethernet" = {
      enable = true;
      matchConfig.PermanentMACAddress = "B0:26:28:C2:C7:20";

      dns = [
        "1.1.1.1"
        "1.0.0.1"
      ];

      routes = [
        {
          Gateway = "108.62.157.254";
        }
      ];

      addresses = [
        {
          Address = "108.62.157.229/27";
        }
      ];
    };

    networking.useNetworkd = true;
    networking.firewall.allowedTCPPorts = [
      22
    ];
  };
}
