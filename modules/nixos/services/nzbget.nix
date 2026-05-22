{ pkgs, ... }:
{
  config = {
    services.nzbget.enable = true;
    services.nzbget.settings = {
      MainDir = "/media/downloads/nzbget";
      ControlIP = "127.0.0.1";
      "Category5.Name" = "Prowlarr";
      "UnrarCmd" = "${pkgs.unrar}/bin/unrar";
      "SevenZipCmd" = "${pkgs.p7zip}/bin/7z";
    };
  };
}
