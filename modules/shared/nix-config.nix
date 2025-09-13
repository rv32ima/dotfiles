{
  pkgs,
  ...
}:
{
  nix.package = pkgs.lix;
  nix.settings = {
    experimental-features = "nix-command flakes";
    # Don't cache tarballs so that we can pull updates to flakes quicker
    tarball-ttl = 0;
  };
}
