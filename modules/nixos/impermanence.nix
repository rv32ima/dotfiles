{
  pkgs,
  lib,
  config,
  ...
}:
{
  options = {
    rv32ima.machine.impermanence.enable = lib.mkEnableOption "impermanence";
    rv32ima.machine.impermanence.extraPersistDirectories = lib.mkOption {
      type = lib.types.listOf (
        lib.types.submodule {
          options = {
            path = lib.mkOption {
              type = lib.types.str;
            };
            mode = lib.mkOption {
              type = lib.types.str;
            };
            owner = lib.mkOption {
              type = lib.types.str;
            };
            group = lib.mkOption {
              type = lib.types.str;
            };
          };
        }
      );
      default = [
        {
          path = "/var/log";
          mode = "0644";
          owner = "root";
          group = "root";
        }
        {
          path = "/var/lib/nixos";
          mode = "0644";
          owner = "root";
          group = "root";
        }
        {
          path = "/var/lib/systemd/coredump";
          mode = "0644";
          owner = "root";
          group = "root";
        }
        {
          path = "/var/lib/systemd/timers";
          mode = "0644";
          owner = "root";
          group = "root";
        }
        {
          path = "/var/lib/tailscale";
          mode = "0644";
          owner = "root";
          group = "root";
        }
      ];
    };
  };

  config = lib.mkIf config.rv32ima.machine.impermanence.enable {
    services.openssh.hostKeys = [
      {
        path = "/persist/etc/ssh/ssh_host_ed25519_key";
        type = "ed25519";
      }
      {
        path = "/persist/etc/ssh/ssh_host_rsa_key";
        type = "rsa";
        bits = 4096;
      }
    ];

    systemd.tmpfiles.rules = lib.lists.flatten (
      [
        "d /persist/etc/ssh 0644 root root"
      ]
      ++ (builtins.map (
        {
          path,
          mode,
          owner,
          group,
        }:
        [
          "d \"/persist${path}\" ${mode} ${owner} ${group}"
        ]
      ) config.rv32ima.machine.impermanence.extraPersistDirectories)
    );

    fileSystems = builtins.listToAttrs (
      builtins.map (
        { path, ... }:
        {
          name = path;
          value = {
            device = "/persist${path}";
            options = [ "bind" ];
          };
        }
      ) config.rv32ima.machine.impermanence.extraPersistDirectories
    );

    boot.initrd.systemd.enable = true;
    boot.initrd.systemd.services.zfs-rollback = {
      enable = true;
      after = [
        "zfs-import-zroot.service"
      ];
      wantedBy = [
        "initrd.target"
      ];
      before = [
        "sysroot.mount"
      ];
      unitConfig.DefaultDependencies = "no";
      serviceConfig.Type = "oneshot";
      script = ''
        ${pkgs.zfs}/bin/zfs rollback -r zroot/root@blank && echo "zfs rollback complete"
      '';
    };
  };
}
