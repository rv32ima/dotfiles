{
  pkgs,
  ...
}:
{
  home.stateVersion = "25.05";
  home.packages = with pkgs; [
    p7zip-rar
  ];

  users.users."ellie" = {
    openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIGPUAs4RQBUriBrp7rv2cepCve5eIo6uqFfgs7oPqV9Q" # 1Password -> 'Primary SSH key'
    ];
    isNormalUser = true;

    group = "wheel";
    shell = pkgs.fish;
    createHome = true;
  };
}
