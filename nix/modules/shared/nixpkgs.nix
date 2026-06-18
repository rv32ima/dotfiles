{
  inputs,
  ...
}:
{
  config = {
    nixpkgs.config.allowUnfree = true;
    nixpkgs.overlays = [
      inputs.rust-overlay.overlays.default
      inputs.zig.overlays.default
    ];
  };
}
