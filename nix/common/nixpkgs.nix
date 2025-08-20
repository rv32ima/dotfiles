{
  system,
  nixpkgs,
  rust-overlay,
  ...
}: import nixpkgs {
  inherit system;
  config.allowUnfree = true;
  overlays = [
    rust-overlay.overlays.default
  ];
}