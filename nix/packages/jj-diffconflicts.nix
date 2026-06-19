{
  vimUtils,
  vimPlugins,
  fetchFromGitHub,
  lib,
}:
vimUtils.buildVimPlugin {
  pname = "jj-diffconflicts";
  version = "master";

  src = fetchFromGitHub {
    owner = "rafikdraoui";
    repo = "jj-diffconflicts";
    rev = "a2aa9a247b56d2c1a6f6be81bcf41c5450cc82ff";
    hash = "sha256-MjacjGlBRwActBBGeBZDHz8jz5J3Mt6KoDsf8WKgUDA=";
  };
}
