{ lib, ... }:
let
  hash = builtins.hashString "sha256" "tuwunel";
  c = off: builtins.substring off 2 hash;
  mac = "${builtins.substring 0 1 hash}2:${c 2}:${c 4}:${c 6}:${c 8}:${c 10}";
in
{
  microvm.vms.tuwunel.config = {
    system.stateVersion = lib.trivial.release;
    networking.hostName = "tuwunel";
    microvm = {
      hypervisor = "cloud-hypervisor";
      mem = 4096;
      vcpu = 2;
      interfaces =

        [
          {
            inherit mac;
            type = "tap";
            id = "vm-tuwunel";
          }
        ];

      shares = [
        {
          proto = "virtiofs";
          tag = "ro-store";
          source = "/nix/store";
          mountPoint = "/nix/.ro-store";
        }
      ];
    };

    systemd.network.enable = true;
    systemd.network.networks."01-ethernet" = {
      matchConfig.PermanentMACAddress = mac;
      DHCP = "yes";
    };

    users.users.root.password = "toor";
    services.openssh = {
      enable = true;
      settings.PermitRootLogin = "yes";
    };
  };
}
