{ ... }:
{
  "ghostholding" = {
    sshPublicKey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIAJOdJCK9bK++zCrAqJ5qkvakYMZbcWKynbaWo4F30Jk";
    deployment = {
      targetHost = "ghostholding.tail09d5b.ts.net";
      targetPort = 22;
      targetUser = "root";
    };
  };
  "silver-chariot" = {
    sshPublicKey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIFQ1olIhfunqdo3YQO7qNuT894HVrw4OqWehm/KwOYSj";
    deployment = {
      targetHost = "silver-chariot.tail09d5b.ts.net";
      targetPort = 22;
      targetUser = "root";
    };
  };
  "sisterhood" = {
    sshPublicKey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIK/aB3u9QTM6k4LnFNr93GdIuu1jQMtvZ58BbmwvWoDg";
    deployment = {
      targetHost = "sisterhood.tail09d5b.ts.net";
      targetPort = 22;
      targetUser = "root";
    };
  };
  "unmusique" = {
    sshPublicKey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIEqPYLS8MYB5YCS03ID7sHxqnfkoe2yhZ1KeL3lr+quz";
    deployment = {
      targetHost = "unmusique.tail09d5b.ts.net";
      targetPort = 22;
      targetUser = "root";
    };
  };
}
