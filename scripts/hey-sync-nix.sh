#!/bin/sh
set -euo pipefail

# acts like: sudo apt update && sudo apt dist-upgrade

pushd ~/ghq/github.com/ajitid/dotfiles
echo "Updating nixpkgs records..."
./scripts/pvt/hey-update-nix.sh
echo "Applying updates to NixOS..."
./scripts/pvt/hey-apply-nixos.sh
echo "Applying updates to Home Manager..."
./scripts/pvt/hey-apply-home-manager.sh
popd