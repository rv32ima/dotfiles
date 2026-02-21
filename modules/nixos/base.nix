# Set of sanity-keeping configurations.
# All machines should import this module.

{
  lib,
  self,
  pkgs,
  vars',
  inputs,
  ...
}:

{
  imports = [
    inputs.disko.nixosModules.disko
    inputs.sops-nix.nixosModules.sops
    (self.lib.nixosModule "shared/nix-config")
    (self.lib.nixosModule "shared/nixpkgs")
    (self.lib.nixosModule "nixos/home-manager")
    (self.lib.nixosModule "nixos/tags")
  ];

  systemd.settings.Manager = {
    # Don't wait too long for services to stop:
    DefaultTimeoutStopSec = "15s";
    # Prevent the system from hanging:
    RuntimeWatchdogSec = "5m";
    ShutdownWatchdogSec = "15m";
  };

  services.journald.extraConfig = ''
    SystemMaxUse=2G
    MaxRetentionSec=3month
  '';

  # Probably needed in some systems:
  hardware.enableRedistributableFirmware = true;

  # All overlays.
  nixpkgs.overlays = [
    (final: prev: {
      disko = inputs.disko.packages.${pkgs.system}.default;
    })
  ];

  # Useful tools.
  environment.systemPackages = with pkgs; [
    htop
    jq
    vim
    wget
    disko
    sbctl
    # persistent terminal sessions for ssh
    tmux
    # useful for getting metal host information
    dmidecode
  ];

  environment.sessionVariables = {
    FLAKE = self;
  };

  # Where we are roughly:
  time.timeZone = "America/Los_Angeles";

  # Since impermanence currently screws up machine-id, manually override it to
  # whatever is in vars:
  environment.etc = lib.optionalAttrs (vars' ? machineID) { machine-id.text = vars'.machineID; };
  boot.kernelParams = lib.optional (vars' ? machineID) "systemd.machine_id=${vars'.machineID}";

  # Enable node-exporter by default for Prometheus monitoring.
  services.prometheus.exporters.node = {
    enable = true;
    openFirewall = true;
  };
}
