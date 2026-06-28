{
  vimUtils,
  vimPlugins,
  fetchFromGitHub,
  lib,
}:
vimUtils.buildVimPlugin {
  pname = "direnv.nvim";
  version = "main";

  nvimSkipModules = [
  ];

  src = fetchFromGitHub {
    owner = "rv32ima";
    repo = "direnv.nvim";
    rev = "f09deee1f4f7a134de63317f3a3d980b82c7c7d1";
    hash = "sha256-b5PpmkYWaDGLNcu+36tRR5ycATHYBjs9WrV8/jfmooQ=";
  };
}
