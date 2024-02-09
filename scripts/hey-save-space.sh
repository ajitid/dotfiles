#!/bin/sh
set -euo pipefail

pushd ~/ghq/github.com/ajitid/dotfiles
echo "Trimming home-manager gens..."
./scripts/pvt/hey-trim-generations.sh 2 -1 home-manager
echo "Trimming user gens..."
./scripts/pvt/hey-trim-generations.sh 2 -1 user
echo "Trimming system gens..."
sudo ./scripts/pvt/hey-trim-generations.sh 2 -1 system
popd

echo "Optimising store and GC-ing. This may take few mins..."
nix-store --optimise 
# There's a difference b/w `sudo nix-collect-garbage -d` (removes all except current system gen [NixOS])
# versus `nix-collect-garbage -d` (removes all except current user gen [eg. home-manager]).
# But if `nix-collect-garbage` is run w/o any flag, putting `sudo` or not doesn't make any difference. 
nix-collect-garbage

# Remove trimmed up system gens from the grub boot menu
sudo /run/current-system/bin/switch-to-configuration boot