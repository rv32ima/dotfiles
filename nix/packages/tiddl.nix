{
  python3Packages,
  ffmpeg,
  fetchFromGitHub,
  lib,
  makeWrapper,
}:
python3Packages.buildPythonApplication {
  pname = "tiddl";
  version = "master";

  pyproject = true;

  propagatedBuildInputs = with python3Packages; [
    setuptools
    aiofiles
    aiohttp
    m3u8
    mutagen
    pydantic
    requests
    requests-cache
    typer
    makeWrapper
  ];

  src = fetchFromGitHub {
    owner = "oskvr37";
    repo = "tiddl";
    rev = "05d63d153e000b15908f0beaba7d4a7105406622";
    hash = "sha256-Shud5ph1EA5rgbfrkBASKSMLY4h9HxcQpzO8AGlEbok=";
  };

  postFixup = ''
    mv $out/bin/tiddl $out/bin/.tiddl
    makeWrapper $out/bin/.tiddl $out/bin/tiddl --prefix PATH : ${lib.makeBinPath [ ffmpeg ]}
  '';
}
