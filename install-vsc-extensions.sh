#!/bin/bash

if [ ! -d "$HOME/.vscode-server" ]; then
  exit 0
fi

EXTENSIONS=(
  'ms-azuretools.vscode-docker'
  'eamodio.gitlens'
  'golang.go'
  'hashicorp.hcl'
  'hashicorp.terraform'
  'foxundermoon.shell-format'
  'redhat.vscode-yaml'
  'timonwong.shellcheck'
)

pushd "$HOME/.vscode-server/cli/servers" || exit 1
INSTALL=$(jq -r '.[0]' lru.json)
pushd "$INSTALL/server/bin/remote-cli" || exit 1
for ext in "${EXTENSIONS[@]}"; do
  ./code --install-extension "$ext"
done
popd || exit 1
popd || exit 1