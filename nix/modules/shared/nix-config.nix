{
  pkgs,
  ...
}:
{
  nix.package = pkgs.lixPackageSets.git.lix.overrideAttrs {
    doCheck = false;
    doInstallCheck = false;
  };

  nix.settings = {
    experimental-features = "nix-command flakes";
    # Don't cache tarballs so that we can pull updates to flakes quicker
    tarball-ttl = 0;
  };
}
