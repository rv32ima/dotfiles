#!/bin/bash

set -eu

ARCH=$(uname -m)
OS=$(uname -o)
GOOS=""
GOARCH=""
GOVERSION="${GOVERSION:-1.22.2}"
QUIET=""
RC=0

err() {
  printf "$@" >&2
}

case "$ARCH" in
  x86_64)
    GOARCH="amd64"
    ;;
  arm64)
    GOARCH="arm64"
    ;;
  arm)
    GOARCH="arm"
    ;;
  *)
    err 'Unsupported architecture %s\n' "$ARCH"
    exit 1
    ;;
esac

case "$OS" in
  *Linux*)
    GOOS="linux"
    ;;  
  Darwin)
    GOOS="darwin"
    ;;
  *)
    err 'Unsupported OS %s\n' "$OS"
    exit 1
    ;;
esac

SUDO=
if [ "$(id -u)" = 0 ]; then
  SUDO=""
elif type sudo >/dev/null; then
  SUDO="sudo"
elif type doas >/dev/null; then
  SUDO="doas"
fi

CURL=""
if type curl >/dev/null; then
  CURL="curl -fsSL --output -"
elif type wget >/dev/null; then
  CURL="wget -q -O-"
fi

wait_for_program() {
  PID=$!
  if [ -n "$QUIET" ]; then
    while kill -0 $PID 2>/dev/null; do
      sleep .1
    done
    wait $PID
    return
  fi

  # Some spacing just so we don't overwrite the contents written before us...
  err "  "
  # Wait for the forked program to finish
  while kill -0 $PID 2>/dev/null; do
    for i in '-' '/' '|' '\'; do
      err '\b%s' "$i"
      sleep .1
    done
  done
  # Replace the spinner with a space
  err "\b \n"
  # populate RC with the exit code of this command, so
  # we can handle it
  wait $PID || RC=$?
}

DIR=$(mktemp -d)
trap "rm -r $DIR" EXIT
pushd "$DIR"

URL="https://go.dev/dl/go$GOVERSION.$GOOS-$GOARCH.tar.gz"
$CURL "$URL" >"go.tar.gz" &
wait_for_program
if [ $RC != 0 ]; then
  err "Couldn't download go from %s, got exit code %d\n" "$URL" "$RC"
  exit 1
fi

$SUDO sh -c "rm -rf /usr/local/go"
$SUDO tar -C /usr/local -xzf ./go.tar.gz