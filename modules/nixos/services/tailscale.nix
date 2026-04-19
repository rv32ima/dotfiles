{
  config,
  lib,
  pkgs,
  inputs,
  ...
}:
{
  options = {
    rv32ima.machine.tailscale.enable = lib.mkEnableOption "tailscale";
    rv32ima.machine.tailscale.services = lib.mkOption {
      type = lib.types.attrsOf (
        lib.types.submodule (
          { config, ... }:
          {
            options = {
              name = lib.mkOption {
                type = lib.types.str;
                default = config._module.args.name;
              };
              tag = lib.mkOption {
                type = lib.types.str;
                default = config.name;
              };
              port = lib.mkOption {
                type = lib.types.port;
              };
              targetUnit = lib.mkOption {
                type = lib.types.str;
                default = "${config.name}.service";
              };
            };

          }
        )
      );
      default = { };
    };
  };

  config = lib.mkIf config.rv32ima.machine.tailscale.enable {
    services.tailscale.enable = true;
    services.tailscale.package =
      let
        pkgsUnstable = import inputs.nixpkgs-unstable {
          system = pkgs.stdenv.hostPlatform.system;
        };
      in
      pkgsUnstable.tailscale;
    services.tailscale.openFirewall = true;
    services.tailscale.useRoutingFeatures = "both";
    services.tailscale.extraSetFlags = [ "--accept-routes" ];
    networking.firewall.trustedInterfaces = [ "tailscale0" ];

    systemd.services = lib.mapAttrs' (
      _:
      {
        name,
        tag,
        port,
        targetUnit,
      }:
      lib.nameValuePair "${name}-serve" {
        wantedBy = [ targetUnit ];
        after = [
          targetUnit
          "tailscaled.service"
        ];
        wants = [
          "tailscaled.service"
        ];
        unitConfig = {
          BindsTo = [ targetUnit ];
        };
        serviceConfig = {
          RemainAfterExit = "yes";
          Type = "oneshot";
          ExecStart = pkgs.writeShellScript "${name}-serve" ''
            ${config.services.tailscale.package}/bin/tailscale serve --service=svc:${tag} --https=443 ${builtins.toString port}
          '';
          ExecStop = pkgs.writeShellScript "${name}-serve-clear" ''
            ${config.services.tailscale.package}/bin/tailscale serve clear svc:${tag}
          '';
        };
      }
    ) config.rv32ima.machine.tailscale.services;
  };
}
