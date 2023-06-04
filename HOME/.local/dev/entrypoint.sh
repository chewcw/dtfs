#!/bin/bash

set -e

FISH=$(which fish)

# fetch latest neovim configuration
curl https://raw.githubusercontent.com/chewcw/dtfs/main/install-nvim.sh | bash -s update

if [ $# -eq 0 ]; then
  $FISH
else
  $FISH -c "$@"
fi
