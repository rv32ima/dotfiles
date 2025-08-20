#!/bin/bash

EXTENSIONS=(
  'ms-azuretools.vscode-docker'
  'eamodio.gitlens'
  'golang.go'
  'hashicorp.hcl'
  'hashicorp.terraform'
  'foxundermoon.shell-format'
  'redhat.vscode-yaml'
  'timonwong.shellcheck'
  'tamasfe.even-better-toml'
  'rust-lang.rust-analyzer'
  'sumneko.lua'
  'ms-vscode.makefile-tools'
)

if [ -x "$(which code)" ]; then
  echo "Using the 'code' binary to install extensions."
  for ext in "${EXTENSIONS[@]}"; do
    code --install-extension "$ext"
  done
else
  if [ ! -d "$HOME/.vscode-server" ]; then
    echo "Could not find an installation of VS Code Server - exiting"
    exit 0
  fi
  pushd "$HOME/.vscode-server/cli/servers" || exit 1
  INSTALL=$(jq -r '.[0]' lru.json)
  pushd "$INSTALL/server/bin/remote-cli" || exit 1
  for ext in "${EXTENSIONS[@]}"; do
    ./code --install-extension "$ext"
  done
  popd || exit 1
  popd || exit 1
fi
