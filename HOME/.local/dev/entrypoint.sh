#!/bin/bash

set -e

ZSH=$(which zsh)

# fetch latest neovim configuration
curl -fsSL https://raw.githubusercontent.com/chewcw/dtfs/main/install-nvim.sh | bash -s update

if [ $# -eq 0 ]; then
  $ZSH
else
  $ZSH -c "$@"
fi
