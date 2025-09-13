{
  pkgs,
  ...
}:
{
  home.stateVersion = "25.05";
  home.packages = with pkgs; [
    p7zip-rar
  ];


}
