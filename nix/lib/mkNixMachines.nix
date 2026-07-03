# Stolen from https://github.com/NixOS/nixpkgs/blob/nixos-26.05/nixos/modules/config/nix-remote-build.nix
{
  lib,
  ...
}:
buildMachines:
let
  inherit (lib)
    concatMapStrings
    concatStringsSep
    optionalString
    ;

  buildMachinesText = concatMapStrings (
    machine:
    (concatStringsSep " " ([
      "${optionalString (machine.protocol != null) "${machine.protocol}://"}${
        optionalString (machine.sshUser != null) "${machine.sshUser}@"
      }${machine.hostName}"
      (
        if machine.system != null then
          machine.system
        else if machine.systems != [ ] then
          concatStringsSep "," machine.systems
        else
          "-"
      )
      (if machine.sshKey != null then machine.sshKey else "-")
      (toString machine.maxJobs)
      (toString machine.speedFactor)
      (
        let
          res = (machine.supportedFeatures ++ machine.mandatoryFeatures);
        in
        if (res == [ ]) then "-" else (concatStringsSep "," res)
      )
      (
        let
          res = machine.mandatoryFeatures;
        in
        if (res == [ ]) then "-" else (concatStringsSep "," machine.mandatoryFeatures)
      )
      (if machine.publicHostKey != null then machine.publicHostKey else "-")
    ]))
    + "\n"
  ) buildMachines;
in
buildMachinesText
