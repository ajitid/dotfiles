#!/bin/sh
set -euo pipefail

# Setup nix hardware
sudo nix-channel --add https://github.com/NixOS/nixos-hardware/archive/master.tar.gz nixos-hardware
sudo nix-channel --update

# Setup home-manager
nix-channel --add https://github.com/nix-community/home-manager/archive/release-23.11.tar.gz home-manager
nix-channel --update

# Setup devenv
#nix-env -iA cachix -f https://cachix.org/api/v1/install
# --- i install cachix directly on nixos now so maybe the above cmd is not needed anymore (while the below ones still do)
#cachix use devenv
# May fail if DNS is not setup (won't be able to find githubusercontent in JioFiber).
# If that's the case then reboot and re-run this script.
#nix-env -if https://install.devenv.sh/latest
