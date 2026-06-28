{
  vimUtils,
  vimPlugins,
  fetchFromGitHub,
  lib,
}:
vimUtils.buildVimPlugin {
  pname = "direnv.nvim";
  version = "0-unstable-2026-06-28";
  src = fetchFromGitHub {
    owner = "NotAShelf";
    repo = "direnv.nvim";
    rev = "9258f9f10c4c729d8296fce0e3ecb12543daad06";
    hash = "sha256-b5PpmkYWaDGLNcu+36tRR5ycATHYBjs9WrV8/jfmooQ=";
  };
  meta.homepage = "https://github.com/NotAShelf/direnv.nvim/";
  meta.license = lib.licenses.mpl20;
  meta.hydraPlatforms = [ ];
}
