{
  pkgs,
  zls,
  ...
}:
let
in
{
  home = {
    packages = with pkgs; [
      zigpkgs."0.14.1"
      zls.packages.${system}.default

      duckdb
      google-cloud-sdk
      awscli2
      rclone

      tenv
    ];
  };

}
