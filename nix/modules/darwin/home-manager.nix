{
  inputs,
  config,
  self,
  ...
}:
{
  imports = [
    inputs.home-manager.darwinModules.home-manager

  ];

  config = {
    home-manager.useGlobalPkgs = true;
    home-manager.useUserPackages = true;
    home-manager.extraSpecialArgs = {
      inherit inputs;
    };
    home-manager.sharedModules = [
      (self.lib.nixosModule "home-manager/ssh-agent")
    ];
  };
}
