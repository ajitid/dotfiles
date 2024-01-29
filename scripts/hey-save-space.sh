#!/bin/sh
set -euo pipefail

echo "This may take few mins..."
nix-store --optimise 
# There's a difference b/w `sudo nix-collect-garbage -d` (removes all except current system gen [NixOS])
# versus `nix-collect-garbage -d` (removes all except current user gen [eg. home-manager]).
# But if `nix-collect-garbage` is run w/o any flag, putting `sudo` or not doesn't make any difference. 
nix-collect-garbage
