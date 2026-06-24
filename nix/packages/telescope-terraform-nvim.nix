{
  vimUtils,
  vimPlugins,
  fetchFromGitHub,
  lib,
}:
vimUtils.buildVimPlugin {
  pname = "telescope-terraform.nvim";
  version = "master";

  src = fetchFromGitHub {
    owner = "cappyzawa";
    repo = "telescope-terraform.nvim";
    rev = "072c97023797ca1a874668aaa6ae0b74425335df";
    hash = "sha256-uXWW7ewAHZlTF1BDpwgCkB4969PD6K1T5kLte5CJvTg=";
  };
}
