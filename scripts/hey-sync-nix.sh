#!/bin/sh
set -euo pipefail

# acts like: sudo apt update && sudo apt dist-upgrade

pushd ~/ghq/github.com/ajitid/dotfiles
echo "Updating nixpkgs records..."
./scripts/hey-update-nix.sh
echo "Applying updates to NixOS..."
./scripts/hey-apply-nixos.sh
echo "Applying updates to Home Manager..."
./scripts/hey-apply-home-manager.sh
echo "Trimming generations..."
./scripts/hey-trim-gens.sh
popd