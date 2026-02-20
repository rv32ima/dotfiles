{
  config,
  inputs,
  ...
}:
{
  imports = [
    ./common.nix
  ];

  home = {


    file.".config/ghostty/config" = {
      source = "${inputs.self}/ghostty/config";
      recursive = true;
    };

    file.".config/1Password/ssh/agent.toml" = {
      enable = true;
      recursive = true;
      source = ../../1Password/ssh/agent.${config.home.username}.toml;
    };
  };
}
