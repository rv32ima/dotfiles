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
    rv32ima.machine.stateVersion = "25.05";
    rv32ima.machine.platform = "x86_64-linux";
    rv32ima.machine.users = [
      "root"
      "ellie"
    ];
    rv32ima.machine.isRemote = true;

    wsl.enable = true;
    wsl.defaultUser = "ellie";

    environment.systemPackages = with pkgs; [
      wget
    ];
    programs.nix-ld.enable = true;
  };
}
