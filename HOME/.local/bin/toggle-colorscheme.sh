#!/usr/bin/env bash

set -e

# https://github.com/toggle-corp/alacritty-colorscheme/blob/master/README.md
export LIGHT_COLOR='base16-google-light.yml'
export DARK_COLOR='base16-onedark.yml'
$HOME/.local/bin/alacritty-colorscheme -V toggle $LIGHT_COLOR $DARK_COLOR

