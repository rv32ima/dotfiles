{
  vimUtils,
  vimPlugins,
  fetchFromGitHub,
  lib,
}:
vimUtils.buildVimPlugin {
  pname = "telescope-terraform-doc.nvim";
  version = "master";

  src = fetchFromGitHub {
    owner = "ANGkeith";
    repo = "telescope-terraform-doc.nvim";
    rev = "66987fac94d12704fdfd90b857f4f648e31251c9";
    hash = "sha256-yv+/pabR/Reaj5+DSmHhW/viPdqLlq58bekY1lKVGhE=";
  };
}
