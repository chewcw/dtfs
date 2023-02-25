#!/usr/bin/env bash

grep -rn -E "set background=dark" $HOME/.config/nvim/init.vim
if [ "$?" -eq 0 ]; then
    sed -i "s/set background=dark/set background=light/" $HOME/.config/nvim/init.vim
else
    sed -i "s/set background=light/set background=dark/" $HOME/.config/nvim/init.vim
fi

# https://github.com/toggle-corp/alacritty-colorscheme/blob/master/README.md
export LIGHT_COLOR='base16-google-light-256.yml'
export DARK_COLOR='base16-material-256.yml'
$HOME/.local/bin/alacritty-colorscheme -V toggle $LIGHT_COLOR $DARK_COLOR
