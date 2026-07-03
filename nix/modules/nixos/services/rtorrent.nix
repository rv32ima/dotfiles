{ pkgs, config, ... }:
{
  config = {
    rv32ima.machine.impermanence.extraPersistDirectories = [
      {
        path = /var/lib/rtorrent;
        mode = "0770";
        owner = "rtorrent";
        group = "rtorrent";
      }
      {
        path = /var/lib/rutorrent;
        mode = "0775";
        owner = "rutorrent";
        group = "rutorrent";
      }
    ];

    services.rtorrent.enable = true;
    services.rtorrent.openFirewall = true;
    services.rtorrent.downloadDir = "/media/downloads/rtorrent";
    services.rtorrent.configText = ''
      system.umask.set = 0000
      network.http.max_open.set = 4000
      network.max_open_files.set = 10000
      network.max_open_sockets.set = 10000
      pieces.memory.max.set = 16384M
      network.xmlrpc.size_limit.set = 4M
    '';
    systemd.services."rtorrent".serviceConfig.LimitNOFILE = "262144";
    services.nginx.appendHttpConfig = ''
        server {
          listen 127.0.0.1:5050;
          server_name localhost;
          location / {
              include ${pkgs.nginx}/conf/scgi_params;
              scgi_pass unix:/run/rtorrent/rpc.sock;
          }
        }
        server {
          listen 127.0.0.1:80;
          server_name rutorrent.tail09d5b.ts.net ;
          root /var/lib/rutorrent;
          location ~ [^/]\.php(/|$) {
              fastcgi_split_path_info ^(.+?\.php)(/.*)$;
              if (!-f $document_root$fastcgi_script_name) {
                  return 404;
              }
              # Mitigate https://httpoxy.org/ vulnerabilities
              fastcgi_param HTTP_PROXY "";
              fastcgi_pass unix:/run/phpfpm/rutorrent.sock;
              fastcgi_index index.php;
              include /nix/store/cf5mwsjkxjvm0pkk4p4vbn11wq2ii0kd-nginx-1.30.2/conf/fastcgi.conf;
          }
      }
    '';
    users.groups."rtorrent".members = [
      "nginx"
    ];

    services.rutorrent.enable = true;
    services.rutorrent.hostName = "rutorrent.tail09d5b.ts.net";
    # Manually manage the rutorrent nginx config because it's horribly insecure
    services.rutorrent.nginx.enable = false;

    rv32ima.machine.tailscale.services.rutorrent = {
      port = 80;
      targetUnit = "phpfpm-rutorrent.service";
    };
  };
}
