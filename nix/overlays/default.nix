{ inputs, ... }:
final: prev:
let
  packagesDir = prev.lib.makeScope prev.newScope (
    self:
    (prev.lib.packagesFromDirectoryRecursive {
      inherit (self) callPackage;
      directory = ../packages;
    })
  );
in
{
  rv32ima = packagesDir;

  lib = prev.lib // {
    toBase64 = final.callPackage ../lib/toBase64.nix { };
  };
}
