#!/bin/sh
set -euo pipefail

pushd ~/ghq/github.com/ajitid/dotfiles
./scripts/hey-trim-generations.sh 2 0 home-manager
./scripts/hey-trim-generations.sh 2 0 user
sudo ./scripts/hey-trim-generations.sh 2 0 system
popd