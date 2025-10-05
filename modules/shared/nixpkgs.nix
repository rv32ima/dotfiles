{
  system,
  inputs,
  ...
}:
import inputs.nixpkgs {
  inherit system;
  config.allowUnfree = true;
  overlays = [
    inputs.rust-overlay.overlays.default
    inputs.zig.overlays.default
    inputs.lix-module.overlays.default
  ];
}
