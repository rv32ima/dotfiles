{
  config,
  inputs,
  options,
  pkgs,
  self,
  ...
}:
let
  pkgsUnstable = import inputs.nixpkgs-unstable {
    system = config.rv32ima.machine.platform;
  };
in
{
  imports = [
    (self.lib.nixosModule "nixos/impermanence")
    (self.lib.nixosModule "nixos/remote-builder")

    (self.lib.userModule "root")
    (self.lib.userModule "ellie")

    ./network.nix
    ./disk-config.nix
  ];

  config = {
    rv32ima.machine.impermanence.enable = true;
    rv32ima.machine.impermanence.extraPersistDirectories = [
      {
        path = /var/lib/slskd;
        mode = "0770";
        owner = "slskd";
        group = "slskd";
      }
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
      {
        path = /var/lib/radarr/.config/Radarr;
        mode = "0770";
        owner = "radarr";
        group = "radarr";
      }
      {
        path = /var/lib/syncthing;
        mode = "0770";
        owner = "syncthing";
        group = "syncthing";
      }
      {
        path = /var/lib/sonarr/.config/NzbDrone;
        mode = "0770";
        owner = "sonarr";
        group = "sonarr";
      }
    ];
    rv32ima.machine.remote-builder.enable = true;

    services.getty.autologinUser = "root";

    boot.initrd.availableKernelModules = [
      "ahci"
      "xhci_pci"
      "megaraid_sas"
      "usbhid"
      "usb_storage"
      "sd_mod"
      "sr_mod"
    ];
    boot.initrd.kernelModules = [ ];
    boot.kernelModules = [ "kvm-intel" ];
    boot.extraModulePackages = [ ];

    # head -c4 /dev/urandom | od -A none -t x4
    networking.hostId = "a41ae525";

    services.tailscale.enable = true;
    services.tailscale.package = pkgsUnstable.tailscale;
    services.tailscale.openFirewall = true;
    services.tailscale.useRoutingFeatures = "both";
    services.tailscale.extraSetFlags = [ "--accept-routes" ];
    networking.firewall.trustedInterfaces = [ "tailscale0" ];

    services.prometheus.exporters.node.enable = true;

    services.openssh.enable = true;
    services.openssh.openFirewall = false;

    programs.fish.enable = true;
    programs.fish.useBabelfish = true;

    networking.useNetworkd = true;
    networking.firewall.allowedTCPPorts = [ ];
    networking.firewall.logRefusedConnections = false;

    services.plex.enable = true;
    services.plex.openFirewall = true;
    services.plex.dataDir = "/persist/var/lib/plex";

    sops.secrets."services/soulseek/environment" = {
      sopsFile = ./secrets/soulseek.yaml;
    };

    services.slskd.enable = true;
    services.slskd.openFirewall = true;
    services.slskd.settings = {
      shares.directories = [
        "/media/music"
      ];
      directories.downloads = "/media/downloads/slskd/complete";
      directories.incomplete = "/media/downloads/slskd/incomplete";
    };
    services.slskd.domain = "slskd.tail09d5b.ts.net";
    services.slskd.environmentFile = config.sops.secrets."services/soulseek/environment".path;

    security.pam.loginLimits = [
      {
        domain = "*";
        item = "nofile";
        type = "-";
        value = "262144";
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
    '';
    users.groups."rtorrent".members = [
      "nginx"
    ];

    services.rutorrent.enable = true;
    services.rutorrent.hostName = "rutorrent.tail09d5b.ts.net";
    services.rutorrent.nginx.enable = true;

    sops.secrets."services/cloudflared/credentials_file" = {
      sopsFile = ./secrets/cloudflared.yaml;
      owner = "root";
    };

    services.cloudflared.enable = true;
    services.cloudflared.tunnels = {
      "sisterhood" = {
        credentialsFile = config.sops.secrets."services/cloudflared/credentials_file".path;
        default = "http_status:404";
        ingress."music.t4t.net" = "http://127.0.0.1:4747";
      };
    };

    services.gonic.enable = true;
    services.gonic.settings = {
      music-path = [
        "/media/music"
      ];
      podcast-path = "/media/podcasts"; # ???
      playlists-path = "/media/playlists"; # ???????
    };

    services.syncthing.enable = true;
    services.syncthing.guiAddress = "0.0.0.0:8384";
    services.syncthing.openDefaultPorts = true;
    services.syncthing.dataDir = "/media/syncthing";
    services.syncthing.databaseDir = "/var/lib/syncthing";
    services.syncthing.configDir = "/etc/syncthing";
    systemd.tmpfiles.rules = [
      "d /etc/syncthing 0644 syncthing syncthing"
    ];
    services.syncthing.systemService = true;
    services.syncthing.user = "syncthing";
    services.syncthing.group = "syncthing";
    services.syncthing.overrideDevices = true;
    services.syncthing.overrideFolders = true;
    services.syncthing.settings = {
      devices = {
        "gold-experience" = {
          id = "E6AB7XY-6JCMYME-7ZPIPEK-4G6K5IF-TL2QOL2-6VBS727-44O2T3W-GGNAWAP";
        };
      };
      folders = {
        "Music" = {
          path = "/media/music";
          devices = [ "gold-experience" ];
        };
      };
    };

    services.radarr.enable = true;
    services.sonarr.enable = true;
    services.prowlarr.enable = true;

    sops.secrets."services/unpackerr/environment" = {
      sopsFile = ./secrets/unpackerr.yaml;
    };

    virtualisation.oci-containers.backend = "podman";
    virtualisation.oci-containers.containers = {
      unpackerr =
        let
          cfg = pkgs.writeTextDir "config/unpackerr.conf" ''
            ####################################################
            ##      Unpackerr Example Configuration File      ##
            ####################################################
            ## The following values are application defaults. ##
            ## Environment Variables may override all values. ##
            ## More configuration help: https://unpackerr.zip ##
            ## Generator: https://notifiarr.com/unpackerr.php ##
            ## -->  Web UI generated config (12/31/2025)  <-- ##
            ####################################################

            ## [true/false] Turn on debug messages in the output. Do not wrap this in quotes.
            ## Recommend trying this so you know what it looks like. I personally leave it on.
            debug = false

            ## Disable writing messages to stdout/stderr. This silences the app. Set a log
            ## file below if you set this to true. Recommended when starting with systemctl.
            quiet = false

            ## Send error output to stderr instead of stdout by setting error_stderr to true.
            ## Recommend leaving this at false. Ignored if quiet (above) is true.
            error_stderr = false

            ## Setting activity to true will silence all app queue log lines with only zeros.
            ## Set this to true when you want less log spam.
            activity = false

            ## The Starr-application activity queue is logged on an interval.
            ## Adjust that interval with this setting.
            ## Default is a minute. 2m, 5m, 10m, 30m, 1h are also perfectly acceptable.
            log_queues = "1m"

            ## Write messages to a log file. This is the same data that is normally output to stdout.
            ## This setting is great for Docker users that want to export their logs to a file.
            ## The alternative is to use syslog to log the output of the application to a file.
            ## Default is no log file; this is unset. log_files=0 turns off auto-rotation.
            ## Default files is 10 and size(mb) is 10 Megabytes; both doubled if debug is true.
            #log_file = '''/downloads/unpackerr.log'''
            log_files = 10
            log_file_mb = 10

            ## How often to poll starr apps (sonarr, radarr, etc).
            ## Recommend 1m-5m. Uses Go Duration.
            interval = "1m"

            ## How long an item must be queued (download complete) before extraction will start.
            ## One minute is the historic default and works well. Set higher if your downloads
            ## take longer to finalize (or transfer locally). Uses Go Duration.
            start_delay = "1m"

            ## How long to wait before removing the history for a failed extraction.
            ## Once the history is deleted the item will be recognized as new and
            ## extraction will start again. Uses Go Duration.
            retry_delay = "5m"

            ## How many times to retry a failed extraction. Pauses retry_delay between attempts.
            max_retries = 3

            ## How many files may be extracted in parallel. 1 works fine.
            ## Do not wrap the number in quotes. Raise this only if you have fast disks and CPU.
            parallel = 1

            ## Use these configurations to control the file modes used for newly extracted
            ## files and folders. Recommend 0644/0755 or 0666/0777.
            file_mode = "0644"
            dir_mode = "0755"

            ###############################################################################
            ##-IMPORTANT-#######-READ THIS!!!-################ Seriously, read this. ######
            ###############################################################################
            ## The following sections can be repeated if you have more than one Sonarr,  ##
            ## Radarr, Lidarr, Readarr, Whisparr, Folder, Webhook, and/or Command Hook.  ##
            ## You MUST uncomment the [[header]], url and api_key at for any Starr app.  ##
            ## The [[sonarr]] and [[radarr]] headers come uncommented. Uncomment the url ##
            ## and api_key if they are in use. Comment them with a hash if they are not. ##
            ## Uncomment the [[lidarr]] and/or [[readarr]] headers and values if in use. ##
            ###############################################################################
            ###############################################################################
            ##           ALL LINES BEGINNING WITH A HASH # ARE IGNORED COMMENTS          ##
            ##           REMOVE THE HASH # FROM CONFIG LINES YOU WANT TO CHANGE          ##
            ###############################################################################
            ###############################################################################

            #[[lidarr]]
            #url = "http://127.0.0.1:8686"
            #api_key = "0123456789abcdef0123456789abcdef"
            ## File system path where downloaded Lidarr items are located.
            #paths = ['/downloads']
            ## Default protocols is torrent. Alternative: "torrent,usenet"
            #protocols = "torrent"
            ## How long to wait for a reply from the backend.
            #timeout = "10s"
            ## How long to wait after import before deleting the extracted items.
            #delete_delay = "5m"
            ## If you use this app with NZB you may wish to delete archives after extraction.
            ## General recommendation is: do not enable this for torrent use.
            ## Setting this to true deletes the entire original download folder after import.
            #delete_orig = false
            ## If you use Syncthing, setting this to true will make unpackerr wait for syncs to finish.
            #syncthing = false

            [[radarr]]
            url = "http://host.containers.internal:7878"
            api_key = "0123456789abcdef0123456789abcdef"
            ## File system path where downloaded Radarr items are located.
            #paths = ['/downloads']
            ## Default protocols is torrents. Alternative: "torrent,usenet"
            #protocols = "torrent"
            ## How long to wait for a reply from the backend.
            #timeout = "10s"
            ## How long to wait after import before deleting the extracted items.
            #delete_delay = "5m"
            ## If you use this app with NZB you may wish to delete archives after extraction.
            ## General recommendation is: do not enable this for torrent use.
            ## Setting this to true deletes the entire original download folder after import.
            #delete_orig = false
            ## If you use Syncthing, setting this to true will make unpackerr wait for syncs to finish.
            #syncthing = false

            #[[readarr]]
            #url = "http://127.0.0.1:8787"
            #api_key = "0123456789abcdef0123456789abcdef"
            ## File system path where downloaded Readarr items are located.
            #paths = ['/downloads']
            ## Default protocols is torrent. Alternative: "torrent,usenet"
            #protocols = "torrent"
            ## How long to wait for a reply from the backend.
            #timeout = "10s"
            ## How long to wait after import before deleting the extracted items.
            #delete_delay = "5m"
            ## If you use this app with NZB you may wish to delete archives after extraction.
            ## General recommendation is: do not enable this for torrent use.
            ## Setting this to true deletes the entire original download folder after import.
            #delete_orig = false
            ## If you use Syncthing, setting this to true will make unpackerr wait for syncs to finish.
            #syncthing = false

            [[sonarr]]
            url = "http://host.containers.internal:8989"
            api_key = "0123456789abcdef0123456789abcdef"
            ## File system path where downloaded Sonarr items are located.
            #paths = ['/downloads']
            ## Default protocols is torrent. Alternative: "torrent,usenet"
            #protocols = "torrent"
            ## How long to wait for a reply from the backend.
            #timeout = "10s"
            ## How long to wait after import before deleting the extracted items.
            #delete_delay = "5m"
            ## If you use this app with NZB you may wish to delete archives after extraction.
            ## General recommendation is: do not enable this for torrent use.
            ## Setting this to true deletes the entire original download folder after import.
            #delete_orig = false
            ## If you use Syncthing, setting this to true will make unpackerr wait for syncs to finish.
            #syncthing = false

            #[[whisparr]]
            #url = "http://127.0.0.1:6969"
            #api_key = "0123456789abcdef0123456789abcdef"
            ## File system path where downloaded Whisparr items are located.
            #paths = ['/downloads']
            ## Default protocols is torrent. Alternative: "torrent,usenet"
            #protocols = "torrent"
            ## How long to wait for a reply from the backend.
            #timeout = "10s"
            ## How long to wait after import before deleting the extracted items.
            #delete_delay = "5m"
            ## If you use this app with NZB you may wish to delete archives after extraction.
            ## General recommendation is: do not enable this for torrent use.
            ## Setting this to true deletes the entire original download folder after import.
            #delete_orig = false
            ## If you use Syncthing, setting this to true will make unpackerr wait for syncs to finish.
            #syncthing = false


            ##################################################################################
            ### ###  STOP HERE ### STOP HERE ### STOP HERE ### STOP HERE #### STOP HERE  ### #
            ### Only using Starr apps? The things above. The below configs are OPTIONAL. ### #
            ##################################################################################

            ################
            ### Webhooks ###
            ################
            # Sends a webhook when an extraction queues, starts, finishes, and/or is deleted.
            # Created to integrate with notifiarr.com.
            # Also works natively with Discord.com, Telegram.org, and Slack.com webhooks.
            # Can possibly be used with other services by providing a custom template_path.
            ###### Don't forget to uncomment [[webhook]] and url at a minimum !!!!
            #[[webhook]]
            #url = "https://notifiarr.com/api/v1/notification/unpackerr/api_key_from_notifiarr_com"
            #name = ""
            #silent = true
            #events = []
            ## Advanced Optional Webhook Configuration
            #nickname = ""
            #channel = ""
            #exclude = []
            #template_path = ''''''
            #template = ""
            #ignore_ssl = true
            #timeout = "10s"
            #content_type = "application/json"

            ##-Folders-#######################################################################
            ## This application can also watch folders for things to extract. If you copy a ##
            ## subfolder into a watched folder (defined below) any extractable items in the ##
            ## folder will be decompressed. This has nothing to do with Starr applications. ##
            ##################################################################################
            #[[folder]]
            #path = '''/some/folder/to/watch'''
            ## Path to extract files to. The default (leaving this blank) is the same as `path` (above).
            #extract_path = ''''''
            ## Delete extracted or original files this long after extraction.
            ## The default is 0. Set to 0 to disable all deletes. Uncomment it to enable deletes. Uses Go Duration.
            #delete_after = "10m"
            ## Unpackerr extracts archives inside archives. Set this to true to disable recursive extractions.
            #disable_recursion = false
            ## Delete extracted files after successful extraction? true/false, no quotes. Honors delete_after.
            #delete_files = false
            ## Delete original items after successful extraction? true/false, no quotes. Honors delete_after.
            #delete_original = false
            ## Disable extraction log (unpackerred.txt) file creation? true/false, no quotes.
            #disable_log = false
            ## Move extracted files into original folder? If false, files go into an _unpackerred folder.
            #move_back = false
            ## Set this to true if you want this app to extract ISO files with .iso extension.
            #extract_isos = false
            #interval = "2m"

            #####################
            ### Command Hooks ###
            #####################
            # Executes a script or command when an extraction queues, starts, finishes, and/or is deleted.
            # All data is passed in as environment variables. Try /usr/bin/env to see what variables are available.
            ###### Don't forget to uncomment [[cmdhook]] at a minimum !!!!
            #[[cmdhook]]
            #command = '''/my/cool/app'''
            #shell = false
            #name = ""
            #silent = false
            #events = ['0']
            ## Optional Command Hook Configuration
            #exclude = []
            #timeout = "10s"

            #[webserver]
            ## The web server currently only supports metrics; set this to true if you wish to use it.
            #metrics = false
            ## This may be set to a port or an ip:port to bind a specific IP. 0.0.0.0 binds ALL IPs.
            #listen_addr = "0.0.0.0:5656"
            ## Recommend setting a log file for HTTP requests. Otherwise, they go with other logs.
            #log_file = ''''''
            ## This app automatically rotates logs. Set these to the size and number to keep.
            #log_files = 10
            #log_file_mb = 10
            ## Set both of these to valid file paths to enable HTTPS/TLS.
            #ssl_cert_file = ''''''
            #ssl_key_file = ''''''
            ## Base URL from which to serve content.
            #urlbase = "/"
            ## Upstreams should be set to the IP or CIDR of your trusted upstream proxy.
            ## Setting this correctly allows X-Forwarded-For to be used in logs.
            ## In the future it may control auth proxy trust. Must be a list of strings.
            ## example: upstreams=[ "127.0.0.1/32", "10.1.2.0/24" ]
            #upstreams = []
          '';
        in
        {
          image = "golift/unpackerr:latest";
          autoStart = true;
          environmentFiles = [
            config.sops.secrets."services/unpackerr/environment".path
          ];
          volumes = [
            "/media:/media"
            "${cfg}/config:/config"
          ];
        };
    };
    networking.firewall.interfaces."podman0".allowedTCPPorts = [
      7878
      8989
    ];

    sops.secrets."services/restic/media/password" = {
      sopsFile = ./secrets/restic.yaml;
      owner = config.users.users."restic".name;
      group = config.users.users."restic".group;
      mode = "0440";
    };

    sops.secrets."services/restic/media/rcloneConfig" = {
      sopsFile = ./secrets/restic.yaml;
      owner = config.users.users."restic".name;
      group = config.users.users."restic".group;
      mode = "0440";
    };

    users.users."restic" = {
      enable = true;
      group = "restic";
      isSystemUser = true;
    };

    services.restic.backups."media" = {
      initialize = true;
      repository = "rclone:secret:restic/media";
      user = config.users.users."restic".name;
      paths = [
        "/media"
      ];
      passwordFile = config.sops.secrets."services/restic/media/password".path;
      rcloneConfigFile = config.sops.secrets."services/restic/media/rcloneConfig".path;
    };

    services.prometheus.exporters.restic = {
      enable = true;
      repository = "rclone:secret:restic/media";
      rcloneConfigFile = config.sops.secrets."services/restic/media/rcloneConfig".path;
      passwordFile = config.sops.secrets."services/restic/media/password".path;
    };

    users.groups."restic".members = [
      "restic"
      "restic-exporter"
    ];

    nixpkgs.hostPlatform = "x86_64-linux";
    system.stateVersion = "25.11";
    networking.hostName = "sisterhood";
    networking.domain = "sea.t4t.net";
  };
}
