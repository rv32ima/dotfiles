{ pkgs, ... }:
let
  config = {
    AdvertiseServer = false;
    AllowFallingBlocks = true;
    AllowFireSpread = true;
    AllowPvP = true;
    AnalyzeMode = false;
    AntiAbuse = 0;
    BlockTickChunkRange = 5;
    BlockTickInterval = 300;
    ChatRateLimitMs = 1000;
    ClientConnectionTimeout = 150;
    CompressPackets = true;
    ConfigVersion = "1.7";
    CorruptionProtection = true;
    DefaultRoleCode = "suplayer";
    DefaultSpawn = null;
    DieAboveErrorCount = 100000;
    DieAboveMemoryUsageMb = 50000;
    DieBelowDiskSpaceMb = 400;
    DisableModSafetyCheck = false;
    EntityDebugMode = false;
    FileEditWarning = "PLEASE NOTE: This file is also loaded when you start a single player world. If you want to run a dedicated server without affecting single player, we recommend you install the game into a different folder and run the server from there.";
    GroupChatHistorySize = 20;
    HostedMode = false;
    HostedModeAllowMods = false;
    Ip = null;
    LogBlockBreakPlace = false;
    LogFileSplitAfterLine = 500000;
    LoginFloodProtection = false;
    MapSizeX = 1024000;
    MapSizeY = 256;
    MapSizeZ = 1024000;
    MasterserverUrl = "http://masterserver.vintagestory.at/api/v1/servers/";
    MaxChunkRadius = 12;
    MaxClients = 16;
    MaxClientsInQueue = 0;
    MaxMainThreadBlockTicks = 10000;
    MaxOwnedGroupChannelsPerUser = 10;
    ModDbUrl = "https://mods.vintagestory.at/";
    ModIdBlackList = null;
    ModIdWhiteList = null;
    ModPaths = [
      "Mods"
      "/var/lib/vintagestory/Mods"
    ];
    NextPlayerGroupUid = 10;
    OnlyWhitelisted = false;
    PassTimeWhenEmpty = false;
    Password = null;
    Port = 42420;
    RandomBlockTicksPerChunk = 16;
    RegenerateCorruptChunks = false;
    RepairMode = false;
    Roles = [
      {
        AutoGrant = false;
        Code = "suvisitor";
        Color = "Green";
        DefaultGameMode = 1;
        DefaultSpawn = null;
        Description = "Can only visit this world and chat but not use/place/break anything";
        ForcedSpawn = null;
        LandClaimAllowance = 0;
        LandClaimMaxAreas = 3;
        LandClaimMinSize = {
          X = 5;
          Y = 5;
          Z = 5;
        };
        Name = "Survival Visitor";
        PrivilegeLevel = -1;
        Privileges = [ "chat" ];
        RuntimePrivileges = [ ];
      }
      {
        AutoGrant = false;
        Code = "crvisitor";
        Color = "DarkGray";
        DefaultGameMode = 2;
        DefaultSpawn = null;
        Description = "Can only visit this world, chat and fly but not use/place/break anything";
        ForcedSpawn = null;
        LandClaimAllowance = 0;
        LandClaimMaxAreas = 3;
        LandClaimMinSize = {
          X = 5;
          Y = 5;
          Z = 5;
        };
        Name = "Creative Visitor";
        PrivilegeLevel = -1;
        Privileges = [ "chat" ];
        RuntimePrivileges = [ ];
      }
      {
        AutoGrant = false;
        Code = "limitedsuplayer";
        Color = "White";
        DefaultGameMode = 1;
        DefaultSpawn = null;
        Description = "Can use/place/break blocks only in permitted areas (priv level -1), create/manage player groups and chat";
        ForcedSpawn = null;
        LandClaimAllowance = 0;
        LandClaimMaxAreas = 3;
        LandClaimMinSize = {
          X = 5;
          Y = 5;
          Z = 5;
        };
        Name = "Limited Survival Player";
        PrivilegeLevel = -1;
        Privileges = [
          "controlplayergroups"
          "manageplayergroups"
          "chat"
          "build"
          "useblock"
          "attackcreatures"
          "attackplayers"
          "selfkill"
        ];
        RuntimePrivileges = [ ];
      }
      {
        AutoGrant = false;
        Code = "limitedcrplayer";
        Color = "LightGreen";
        DefaultGameMode = 2;
        DefaultSpawn = null;
        Description = "Can use/place/break blocks in only in permitted areas (priv level -1), create/manage player groups, chat, fly and set his own game mode (= allows fly and change of move speed)";
        ForcedSpawn = null;
        LandClaimAllowance = 0;
        LandClaimMaxAreas = 3;
        LandClaimMinSize = {
          X = 5;
          Y = 5;
          Z = 5;
        };
        Name = "Limited Creative Player";
        PrivilegeLevel = -1;
        Privileges = [
          "controlplayergroups"
          "manageplayergroups"
          "chat"
          "build"
          "useblock"
          "gamemode"
          "freemove"
          "attackcreatures"
          "attackplayers"
          "selfkill"
        ];
        RuntimePrivileges = [ ];
      }
      {
        AutoGrant = false;
        Code = "suplayer";
        Color = "White";
        DefaultGameMode = 1;
        DefaultSpawn = null;
        Description = "Can use/place/break blocks in unprotected areas (priv level 0), create/manage player groups and chat. Can claim an area of up to 8 chunks.";
        ForcedSpawn = null;
        LandClaimAllowance = 262144;
        LandClaimMaxAreas = 3;
        LandClaimMinSize = {
          X = 5;
          Y = 5;
          Z = 5;
        };
        Name = "Survival Player";
        PrivilegeLevel = 0;
        Privileges = [
          "controlplayergroups"
          "manageplayergroups"
          "chat"
          "areamodify"
          "build"
          "useblock"
          "attackcreatures"
          "attackplayers"
          "selfkill"
        ];
        RuntimePrivileges = [ ];
      }
      {
        AutoGrant = false;
        Code = "crplayer";
        Color = "LightGreen";
        DefaultGameMode = 2;
        DefaultSpawn = null;
        Description = "Can use/place/break blocks in all areas (priv level 100), create/manage player groups, chat, fly and set his own game mode (= allows fly and change of move speed). Can claim an area of up to 40 chunks.";
        ForcedSpawn = null;
        LandClaimAllowance = 1310720;
        LandClaimMaxAreas = 6;
        LandClaimMinSize = {
          X = 5;
          Y = 5;
          Z = 5;
        };
        Name = "Creative Player";
        PrivilegeLevel = 100;
        Privileges = [
          "controlplayergroups"
          "manageplayergroups"
          "chat"
          "areamodify"
          "build"
          "useblock"
          "gamemode"
          "freemove"
          "attackcreatures"
          "attackplayers"
          "selfkill"
        ];
        RuntimePrivileges = [ ];
      }
      {
        AutoGrant = false;
        Code = "sumod";
        Color = "Cyan";
        DefaultGameMode = 1;
        DefaultSpawn = null;
        Description = "Can use/place/break blocks everywhere (priv level 200), create/manage player groups, chat, kick/ban players and do serverwide announcements. Can claim an area of up to 4 chunks.";
        ForcedSpawn = null;
        LandClaimAllowance = 1310720;
        LandClaimMaxAreas = 60;
        LandClaimMinSize = {
          X = 5;
          Y = 5;
          Z = 5;
        };
        Name = "Survival Moderator";
        PrivilegeLevel = 200;
        Privileges = [
          "controlplayergroups"
          "manageplayergroups"
          "chat"
          "areamodify"
          "build"
          "useblock"
          "buildblockseverywhere"
          "useblockseverywhere"
          "kick"
          "ban"
          "announce"
          "readlists"
          "attackcreatures"
          "attackplayers"
          "selfkill"
        ];
        RuntimePrivileges = [ ];
      }
      {
        AutoGrant = false;
        Code = "crmod";
        Color = "Cyan";
        DefaultGameMode = 2;
        DefaultSpawn = null;
        Description = "Can use/place/break blocks everywhere (priv level 500), create/manage player groups, chat, kick/ban players, fly and set his own or other players game modes (= allows fly and change of move speed). Can claim an area of up to 40 chunks.";
        ForcedSpawn = null;
        LandClaimAllowance = 1310720;
        LandClaimMaxAreas = 60;
        LandClaimMinSize = {
          X = 5;
          Y = 5;
          Z = 5;
        };
        Name = "Creative Moderator";
        PrivilegeLevel = 500;
        Privileges = [
          "controlplayergroups"
          "manageplayergroups"
          "chat"
          "areamodify"
          "build"
          "useblock"
          "buildblockseverywhere"
          "useblockseverywhere"
          "kick"
          "ban"
          "gamemode"
          "freemove"
          "commandplayer"
          "announce"
          "readlists"
          "attackcreatures"
          "attackplayers"
          "selfkill"
        ];
        RuntimePrivileges = [ ];
      }
      {
        AutoGrant = true;
        Code = "admin";
        Color = "LightBlue";
        DefaultGameMode = 1;
        DefaultSpawn = null;
        Description = "Has all privileges, including giving other players admin status.";
        ForcedSpawn = null;
        LandClaimAllowance = 2147483647;
        LandClaimMaxAreas = 99999;
        LandClaimMinSize = {
          X = 5;
          Y = 5;
          Z = 5;
        };
        Name = "Admin";
        PrivilegeLevel = 99999;
        Privileges = [
          "build"
          "useblock"
          "buildblockseverywhere"
          "useblockseverywhere"
          "attackplayers"
          "attackcreatures"
          "freemove"
          "gamemode"
          "pickingrange"
          "chat"
          "kick"
          "ban"
          "whitelist"
          "setwelcome"
          "announce"
          "readlists"
          "give"
          "areamodify"
          "setspawn"
          "controlserver"
          "tp"
          "time"
          "grantrevoke"
          "root"
          "commandplayer"
          "controlplayergroups"
          "manageplayergroups"
          "selfkill"
        ];
        RuntimePrivileges = [ ];
      }
    ];
    ServerDescription = null;
    ServerIdentifier = null;
    ServerLanguage = "en";
    ServerName = "Vintage Story Server";
    ServerUrl = null;
    SkipEveryChunkRow = 0;
    SkipEveryChunkRowWidth = 0;
    SpawnCapPlayerScaling = 0.5;
    StartupCommands = null;
    TemporaryIpBlockList = false;
    TickTime = 33.3333;
    Upnp = false;
    VerifyPlayerAuth = true;
    VhIdentifier = null;
    WelcomeMessage = "{0} is a faggot";
    WhitelistMode = 0;
    WorldConfig = {
      AllowCreativeMode = true;
      CreatedByPlayerName = null;
      DisabledMods = null;
      MapSizeY = null;
      PlayStyle = "surviveandbuild";
      PlayStyleLangCode = "surviveandbuild-bands";
      RepairMode = false;
      SaveFileLocation = "/var/lib/vintagestory/Saves/default.vcdbs";
      Seed = null;
      WorldConfiguration = null;
      WorldName = "A new world";
      WorldType = "standard";
  "gameMode": "survival",
  "playerlives": "-1",
  "startingClimate": "temperate",
  "spawnRadius": "50",
  "graceTimer": "0",
  "deathPunishment": "drop",
  "droppedItemsTimer": "600",
  "seasons": "enabled",
  "daysPerMonth": "9",
  "harshWinters": "true",
  "blockGravity": "sandgravel",
  "caveIns": "off",
  "allowFallingBlocks": true,
  "allowFireSpread": true,
  "lightningFires": false,
  "allowUndergroundFarming": false,
  "noLiquidSourceTransport": false,
  "playerHealthPoints": "15",
  "playerHealthRegenSpeed": "1",
  "playerHungerSpeed": "1",
  "lungCapacity": "40000",
  "bodyTemperatureResistance": "0",
  "playerMoveSpeed": "1.5",
  "creatureHostility": "aggressive",
  "creatureStrength": "1",
  "creatureSwimSpeed": "2",
  "foodSpoilSpeed": "1",
  "saplingGrowthRate": "1",
  "toolDurability": "1",
  "toolMiningSpeed": "1",
  "propickNodeSearchRadius": "6",
  "microblockChiseling": "stonewood",
  "allowCoordinateHud": true,
  "allowMap": true,
  "colorAccurateWorldmap": false,
  "loreContent": true,
  "clutterObtainable": "ifrepaired",
  "temporalStability": true,
  "temporalStorms": "sometimes",
  "tempstormDurationMul": "1",
  "temporalRifts": "visible",
  "temporalGearRespawnUses": "20",
  "temporalStormSleeping": "0",
  "worldClimate": "realistic",
  "landcover": "0.975",
  "oceanscale": "5",
  "upheavelCommonness": "0.3",
  "geologicActivity": "0.05",
  "landformScale": "1.0",
  "worldWidth": "1024000",
  "worldLength": "1024000",
  "worldEdge": "traversable",
  "polarEquatorDistance": "100000",
  "storyStructuresDistScaling": "1",
  "globalTemperature": "1",
  "globalPrecipitation": "1",
  "globalForestation": "0",
  "globalDepositSpawnRate": "1",
  "surfaceCopperDeposits": "0.12",
  "surfaceTinDeposits": "0.007",
  "snowAccum": "true",
  "allowLandClaiming": true,
  "classExclusiveRecipes": true,
  "auctionHouse": true,
  "playstyle": "surviveandbuild",
  "worldHeight": 384
    };
  };
in
{
  rv32ima.machine.impermanence.extraPersistDirectories = [
    {
      path = /var/lib/vintagestory;
      mode = "0775";
      owner = "vintagestory";
      group = "vintagestory";
    }
  ];

  users.users."vintagestory" = {
    home = "/var/lib/vintagestory";
    uid = 992;
    isSystemUser = true;
    group = "vintagestory";
  };

  users.groups.vintagestory = {
    gid = 989;
  };

  systemd.sockets."vintagestory" = {
    socketConfig = {
      ListenFIFO = "/run/vintagestory.stdin";
      Service = "vintagestory.service";
    };
  };

  systemd.services."vintagestory" =
    let
      configJSON = pkgs.writeTextFile {
        name = "vintagestory-config.json";
        text = builtins.toJSON config;
      };
    in
    {
      script = ''
        rm /var/lib/vintagestory/serverconfig.json || true
        # Yes, you can make changes to your serverconfig.json, but they'll get overwritten the next time
        # you restart your server. So it's a futile affair. Make your changes through Nix or die <3
        cp "${configJSON}" /var/lib/vintagestory/serverconfig.json
        chmod 700 /var/lib/vintagestory/serverconfig.json
        ${pkgs.rv32ima.vintagestory}/VintagestoryServer --dataPath /var/lib/vintagestory
      '';
      serviceConfig = {
        Type = "simple";
        Restart = "always";
        User = "vintagestory";
        Sockets = "vintagestory.socket";
        StandardInput = "socket";
        StandardOutput = "journal";
        StandardError = "journal";
      };
      requires = [
        "network.target"
        "network-online.target"
      ];
      after = [
        "network.target"
        "network-online.target"
      ];
      wantedBy = [
        "multi-user.target"
      ];
    };

  networking.firewall.allowedTCPPorts = [ 42420 ];
  networking.firewall.allowedUDPPorts = [ 42420 ];
}
