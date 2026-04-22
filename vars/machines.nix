{ ... }:
{
  "golden-experience" = {
    system = "x86_64-linux";
    stateVersion = "25.11";
    sshPublicKey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIMr/j1AJxcbzhfsN2iZ7cQnVzmBsJH6FcJxvT8eEUoEL";
    deployment = {
      targetHost = "golden-experience.tail09d5b.ts.net";
      targetPort = 22;
      targetUser = "root";
    };
  };
  "ghostholding" = {
    system = "x86_64-linux";
    stateVersion = "25.11";
    sshPublicKey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIAJOdJCK9bK++zCrAqJ5qkvakYMZbcWKynbaWo4F30Jk";
    deployment = {
      targetHost = "ghostholding.tail09d5b.ts.net";
      targetPort = 22;
      targetUser = "root";
    };
  };
  "silver-chariot" = {
    system = "x86_64-linux";
    stateVersion = "25.11";
    sshPublicKey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIFQ1olIhfunqdo3YQO7qNuT894HVrw4OqWehm/KwOYSj";
    deployment = {
      targetHost = "silver-chariot.tail09d5b.ts.net";
      targetPort = 22;
      targetUser = "root";
    };
    build = {
      maxJobs = 48;
      sshUser = "nix";
      supportedFeatures = [
        "kvm"
        "benchmark"
        "big-parallel"
      ];
    };
  };
  "sisterhood" = {
    system = "x86_64-linux";
    stateVersion = "25.11";
    sshPublicKey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIK/aB3u9QTM6k4LnFNr93GdIuu1jQMtvZ58BbmwvWoDg";
    deployment = {
      targetHost = "sisterhood.tail09d5b.ts.net";
      targetPort = 22;
      targetUser = "root";
    };
  };
  "peer2peer" = {
    system = "x86_64-linux";
    stateVersion = "25.11";
    sshPublicKey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIPz54HjkBeZLYPQMrIaKxl5UmIPcNbHh8L3kNmIgiVRx";
    deployment = {
      targetHost = "peer2peer.home.t4t.net";
      targetPort = 22;
      targetUser = "root";
    };
    build = {
      maxJobs = 24;
      sshUser = "nix";
      supportedFeatures = [
        "kvm"
        "benchmark"
        "big-parallel"
      ];
    };
  };
  "unmusique" = {
    system = "x86_64-linux";
    stateVersion = "25.11";
    sshPublicKey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIEqPYLS8MYB5YCS03ID7sHxqnfkoe2yhZ1KeL3lr+quz";
    deployment = {
      targetHost = "unmusique.tail09d5b.ts.net";
      targetPort = 22;
      targetUser = "root";
    };
    build = {
      maxJobs = 40;
      sshUser = "nix";
      supportedFeatures = [
        "kvm"
        "benchmark"
        "big-parallel"
      ];
    };
  };
}
