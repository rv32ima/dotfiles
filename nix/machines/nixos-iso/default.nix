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

    networking.useNetworkd = true;
    networking.firewall.allowedTCPPorts = [
      22
    ];
  };
}
