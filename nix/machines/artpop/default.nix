{
  pkgs,
  ...
}:
{
  config = {
    system.stateVersion = 6;
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
        # laptop yubikey
        "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQC3PscEKy7GMsV6B5Whal8mst15t9f8ABdt/BMyui/+NzG9i7CMXcO+QoJh3D+obftEqAyOhUaO7iYAMhFnAQ3iXafoUKNCx+7BvCx9rxmXhe/UHw6Y460sDf1Seh8FvpR3jfeBxypifb5yGIOM6+FUKllzazqbV8+wtrTRj15JhnDzzlCGZpJBGGDubC1LoNWpHog9lFfNeUSzeFmJvrREALnuv5gq60idr7ygKsWL2uzGhlmpm4rwWku4K6YB16CrkVmX9MOUj07nd6imWUJ0laE9runR1KM1GxOzCtcfLqHo6wgcJpKFCuoTVHLLakGwoVWJGFmpSnrNRwQtv9bYX3Z2cB1edjYZjMREtCeu4zz7DIpnut19boMhsJQNfAd0AwETSqV1xeYwKRkbQU0RCsRRxEeBGhH3uD1qLKD4PyhcD1HvEtegXoJ1ahujQds7IPXSq23Io4POIKdZ2eghz1UYOK4xu4s1dmd/JHqRu9MNLrdD+HY7C7w+fLpw8R7XF88iEphJUQtPyNrtuzpTNHGDxi9P3N5TFCwzX3+6jGXLCg5/1Ogx5fhERQmVR+PTAamYvEPpQvJV0hRIUKUuzej3+xOr7I5tsaJoRWsor2xNo505vqpBRI7IGyS+vSFjEPfulR96HuVenKKiJ924U40/BQ0/wyVarCgiYwnskw== cardno:17_698_361"
      ];
      isNormalUser = true;

      group = "wheel";
      shell = pkgs.fish;
      createHome = true;
    };
  };
}
