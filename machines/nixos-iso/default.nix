{
  nixpkgs,
  ...
}:
let
  lib = nixpkgs.lib;
in
{
  imports = [
    "${nixpkgs}/nixos/modules/installer/cd-dvd/installation-cd-minimal.nix"
  ];

  config = {
    isoImage.squashfsCompression = "gzip -Xcompression-level 1";
    systemd.services.sshd.wantedBy = lib.mkForce [ "multi-user.target" ];
    users.users.root.openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIGPUAs4RQBUriBrp7rv2cepCve5eIo6uqFfgs7oPqV9Q" # 1Password -> 'Primary SSH key'
    ];

    systemd.network.networks.ethernet = {
      enable = true;
      matchConfig.PermanentMACAddress = "B4:83:51:0F:2B:52";

      dns = [
        "1.1.1.1"
        "1.0.0.1"
      ];

      routes = [
        {
          Gateway = "23.82.194.126";
        }
      ];

      addresses = [
        {
          Address = "23.82.194.70/26";
        }
      ];
    };

    networking.useNetworkd = true;
    networking.firewall.allowedTCPPorts = [
      22
    ];
  };
}
