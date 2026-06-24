{
  vimUtils,
  vimPlugins,
  fetchFromGitHub,
  lib,
}:
vimUtils.buildVimPlugin {
  pname = "lazyjui.nvim";
  version = "master";

  dependencies = [
    vimPlugins.plenary-nvim
  ];

  nvimSkipModules = [
    "lazyjui"
  ];

  src = fetchFromGitHub {
    owner = "MrDwarf7";
    repo = "lazyjui.nvim";
    rev = "3a09082dedc5f1e030025a6f936ce7cb5fbc6b48";
    hash = "sha256-zvNlR833ztEzEKZcqGZ1sIKf2yLo6RqmPRTnn4vBfaM=";
  };
}
