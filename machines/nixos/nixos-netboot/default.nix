{
  modulesPath,
  inputs,
  lib,
  self,
  ...
}:
{
  imports = [
    (self.lib.user "root")
  ];

  config = {
    rv32ima.machine.enable = true;
    rv32ima.machine.hostName = "nixos-netboot";
    rv32ima.machine.stateVersion = "25.11";
    rv32ima.machine.platform = "x86_64-linux";
    rv32ima.machine.isRemote = true;

    environment.systemPackages = [
      inputs.disko.packages.x86_64-linux.default
    ];

    systemd.services.sshd.wantedBy = lib.mkForce [ "multi-user.target" ];
    users.users.root.openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIGPUAs4RQBUriBrp7rv2cepCve5eIo6uqFfgs7oPqV9Q" # 1Password -> 'Primary SSH key'
    ];

    networking.firewall.allowedTCPPorts = [
      22
    ];
  };
}
