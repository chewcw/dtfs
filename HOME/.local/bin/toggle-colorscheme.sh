#!/usr/bin/env bash

set -e

# https://github.com/toggle-corp/alacritty-colorscheme/blob/master/README.md
export LIGHT_COLOR='base16-google-light-256.yml'
export DARK_COLOR='base16-material-256.yml'
$HOME/.local/bin/alacritty-colorscheme -V toggle $LIGHT_COLOR $DARK_COLOR

