#!/bin/sh
set -euo pipefail

pushd ~/ghq/github.com/ajitid/dotfiles
echo "Trimming home-manager gens..."
./scripts/pvt/hey-trim-generations.sh 2 0 home-manager
echo "Trimming user gens..."
./scripts/pvt/hey-trim-generations.sh 2 0 user
echo "Trimming system gens..."
sudo ./scripts/pvt/hey-trim-generations.sh 2 0 system
popd