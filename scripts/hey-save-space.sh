#!/bin/sh
set -euo pipefail

pushd ~/ghq/github.com/ajitid/dotfiles
echo "Trimming generations..."
./scripts/pvt/hey-trim-gens.sh
popd

echo "Optimising store and GC-ing. This may take few mins..."
nix-store --optimise 
# There's a difference b/w `sudo nix-collect-garbage -d` (removes all except current system gen [NixOS])
# versus `nix-collect-garbage -d` (removes all except current user gen [eg. home-manager]).
# But if `nix-collect-garbage` is run w/o any flag, putting `sudo` or not doesn't make any difference. 
nix-collect-garbage
