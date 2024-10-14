{ pkgs, lib, modulesPath, ... }: 
{
  imports = ["${modulesPath}/virtualisation/amazon-image.nix"];

  config = {
    programs.fish.enable = true;

    services.openssh = {
      enable = true;
      settings.PasswordAuthentication = false;
      settings.KbdInteractiveAuthentication = false;
    };

    users.users."ellie" = {
      openssh.authorizedKeys.keys = [
        # wallsocket yubikey
        "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQCfLOzAhOhAbEYi5xDL5PEhSgeYTMTcuoG/k9qFjIfyHh5ROMFwQc0qEDBQMNwTae1nOpHlAfitov3Ukr8tPexlZwioy2XdKiW1oMrTLtAaCzLFmpPl8PWpDoSV4qDXp+QrnD3jPB9TyeSvz9/mCkQfMA1fbzbjg8wZa6Y2AHEjL/+86mhy5eK+sHiZ1YEhphSHJE/lBdICnBul/hzBlsNCr6/J2Bz9lwsFr5WomIIQSfP3IBiYxbQmM/r3rHoKX/BnOKL+cIQsGsb/B+iZjuidSh8rVaGKosWfL5zbaKv6lq7zTroc4NOS1yTnCE5hE7thWYdbqieWgeUNI6LcmhkOWCdU3JNRQLfRirpUnrWmWuuCG2QvUaxGEfy/Kqvy9OJ9BNicCHEVwC2uhFWVhadKoVNaR2Kmek18uo2sPHg7p/NLBi911j0m+UA0/He+mVRLh+Lex6VXiNWtxWMkpSNpN+QGjgZ97SzcAIPPTUbfIl1WKzwtVPf1bMmly7kLsUcHUoQLXSVWsHIeD7BNbuIfWgVHMeTQ97Yie9mxjCOlSFI8naPd73ylg9upDG8XaL0yqRDdVfX3RmM0VQdSH6iNR2WfJGLkpC1PqxTA84f+lF2O+AIBNlgb9OrYB4jAVviw8Hrm0M5iQ9iBHaYZLDUjeKIauOrOP0o58l2mj6ShTw=="
      ];
      isNormalUser = true;
      group = "wheel";
      shell = pkgs.fish;
      createHome = true;
    };
  }; 
}