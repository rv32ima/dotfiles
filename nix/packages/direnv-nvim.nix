{
  vimUtils,
  vimPlugins,
  fetchFromGitHub,
  lib,
}:
vimUtils.buildVimPlugin {
  pname = "direnv-nvim";
  version = "main";

  nvimSkipModules = [
  ];

  src = fetchFromGitHub {
    owner = "NotAShelf";
    repo = "direnv.nvim";
    rev = "e623d3645152839cbe7e73e7b2aa6e31256020ea";
    hash = "sha256-Bwdkf1ZHPsR3BUxdsGBNNNbzJ/CPOIlqb5EcQUUPuAk=";
  };
}
