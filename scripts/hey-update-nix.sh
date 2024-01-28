#!/bin/sh
set -euo pipefail

sudo nix-channel --update
# ↑ for nixos and nixos-hardware | ↓ for home-manager
nix-channel --update
