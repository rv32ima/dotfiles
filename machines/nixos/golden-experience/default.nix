{
  pkgs,
  inputs,
  ...
}:
{
  imports = [
    inputs.nixos-wsl.nixosModules.default
  ];

  config = {
    rv32ima.machine.enable = true;
    rv32ima.machine.hostName = "golden-experience";
    rv32ima.machine.stateVersion = "25.11";
    rv32ima.machine.platform = "x86_64-linux";
    rv32ima.machine.users = [
      "root"
      "ellie"
    ];
    rv32ima.machine.isRemote = true;

    services.openssh.enable = true;
    services.openssh.hostKeys = [
      {
        path = "/etc/ssh/ssh_host_ed25519_key";
        type = "ed25519";
      }
      {
        path = "/etc/ssh/ssh_host_rsa_key";
        type = "rsa";
        bits = 4096;
      }
    ];

    wsl.enable = true;
    wsl.defaultUser = "ellie";

    environment.systemPackages = with pkgs; [
      wget
    ];
    programs.nix-ld.enable = true;
  };
}
