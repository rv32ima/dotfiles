{ pkgs, ... }:
{
  environment.systemPackages = [ pkgs.beets ];

  environment.etc."beets/config.yaml".text = ''
    directory: /media/music
    library: /media/music.db
    import:
      move: no
      copy: no
      quiet: yes
      timid: no
  '';

  environment.etc."beets/lidarr-import.sh" = {
    mode = "0755";
    text = ''
      #!/usr/bin/env bash
      set -euo pipefail
      if [ "$lidarr_eventtype" = "Download" ]; then
        BEETSDIR=/etc/beets ${pkgs.beets}/bin/beet import -q "$lidarr_artist_path"
      fi
    '';
  };
}
