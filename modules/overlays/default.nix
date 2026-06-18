{ inputs, ... }:
final: prev:
let
  packagesDir = (
    prev.lib.makeScope prev.newScope (
      self:
      (prev.lib.packagesFromDirectoryRecursive {
        inherit (self) callPackage;
        directory = ../../packages;
      })
    )
  );
in
packagesDir
