#!/bin/sh
set -euo pipefail

pushd ~/ghq/github.com/ajitid/dotfiles
sudo nixos-rebuild switch -I nixos/configuration.nix
popd