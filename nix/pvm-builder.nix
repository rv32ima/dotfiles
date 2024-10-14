{ pkgs, lib, ... }: 
{
  config = {
    environment.systemPackages = with pkgs; [
      fish
    ];

    users.users."ellie" = {
      isNormalUser = true;
      group = "wheel";
      shell = pkgs.fish;
      createHome = true;
    };
  }; 
}