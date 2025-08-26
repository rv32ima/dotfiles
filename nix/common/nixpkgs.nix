{
  system,
  nixpkgs,
  rust-overlay,
  zig,
  ...
}: import nixpkgs {
  inherit system;
  config.allowUnfree = true;
  overlays = [
    rust-overlay.overlays.default
    zig.overlays.default
  ];
}