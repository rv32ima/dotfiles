#!/bin/bash

set -eu

VERSION='2.18.1'
URL="https://releases.nixos.org/nix/nix-${VERSION}/install"
CONFIGURATION="
extra-experimental-features = nix-command flakes repl-flake
extra-trusted-users = ${USER}
"

sh <(curl --location "${URL}") \
  --no-channel-add \
  --nix-extra-conf-file <(<<< "${CONFIGURATION}")