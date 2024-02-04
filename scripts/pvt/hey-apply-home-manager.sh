#!/bin/sh
set -euo pipefail

pushd ~/ghq/github.com/ajitid/dotfiles
home-manager switch -f home-manager/home.nix
popd