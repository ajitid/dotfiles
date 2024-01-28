#!/bin/sh
set -euo pipefail

# acts like: sudo apt update && sudo apt dist-upgrade

pushd ~/ghq/github.com/ajitid/dotfiles
./scripts/hey-update-nix.sh
./scripts/hey-apply-nixos.sh
./scripts/hey-apply-home-manager.sh
./scripts/hey-save-space.sh
popd