{
  self,
  ...
}:
{
  imports = [
    (self.lib.user "eford-pinterest")
  ];
  config = {
    rv32ima.machine.enable = true;
    rv32ima.machine.hostName = "eford-20RW02G";
    rv32ima.machine.stateVersion = 6;
    rv32ima.machine.primaryUser = "eford";
    rv32ima.machine.platform = "aarch64-darwin";
    rv32ima.machine.isRemote = false;
    rv32ima.machine.workstation.enable = true;

    nix.settings.max-jobs = 10;
    nix.distributedBuilds = true;
  };
}
