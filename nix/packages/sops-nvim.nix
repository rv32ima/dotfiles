{
  vimUtils,
  vimPlugins,
  fetchFromGitHub,
  lib,
}:
vimUtils.buildVimPlugin {
  pname = "sops-nvim";
  version = "master";

  src = fetchFromGitHub {
    owner = "trixnz";
    repo = "sops.nvim";
    rev = "5946285744ffef26b792839d9130135365bfa8ea";
    hash = "sha256-6BFgZSQwrh218genHjnldv1xnCjx4PIoXZcFYKVBlGo=";
  };
}
