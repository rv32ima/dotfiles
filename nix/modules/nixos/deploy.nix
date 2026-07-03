{ pkgs, ... }: {
  config = {
    users.users.deploy = {
      group = "deploy";
      openssh.authorizedKeys.keys = [
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIOovYff9edwaEZfqoRz1VQgiJ3wdCDpebxj5fzHIrFSW" # CI deploy key
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIGPUAs4RQBUriBrp7rv2cepCve5eIo6uqFfgs7oPqV9Q" # 1Password -> 'Primary SSH key'
      ];
      shell = pkgs.bashInteractive;
      isSystemUser = true;
    };

    users.groups.deploy = { };

    nix.trustedUsers = [ "@deploy" ];

    security.sudo.extraRules = [
      # Allow execution of any command by all users in group sudo,
      # requiring a password.
      #
      # This sucks, but Colmena doesn't have any hardening yet: see https://github.com/nix-community/colmena/issues/165
      {
        groups = [ "deploy" ];
        commands = [
          {
            command = "ALL";
            options = [ "NOPASSWD" ];
          }
        ];
      }
    ];
  };
}
