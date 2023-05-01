#!/usr/bin/env bash

# tmux change colorscheme related function
function comment_or_uncomment_line() {
    to_comment=$1
    line_number=$2

    if [[ to_comment -eq 1 && ! $(sed "$line_number!d" $HOME/.tmux.conf) =~ ^# ]]; then
        # comment out the line
        sed -i "${line_number}s/^/# /" $HOME/.tmux.conf;
    fi

    if [[ to_comment -eq 0 && $(sed "$line_number!d" $HOME/.tmux.conf) =~ ^# ]]; then
        # uncomment the line
        sed -i "${line_number}s/# //" $HOME/.tmux.conf;
    fi
}

# tmux change colorscheme related function
function toggle_tmux_colorscheme() {
    is_light_mode=$1

    light_start_line_number=$(awk '/tmux-gruvbox-light START/{ print NR+1; exit }' $HOME/.tmux.conf)
    light_end_line_number=$(awk '/tmux-gruvbox-light END/{ print NR-1; exit }' $HOME/.tmux.conf)
    dark_start_line_number=$(awk '/tmux-gruvbox-dark START/{ print NR+1; exit }' $HOME/.tmux.conf)
    dark_end_line_number=$(awk '/tmux-gruvbox-dark END/{ print NR-1; exit }' $HOME/.tmux.conf)

    if [[ $is_light_mode -eq 1 ]]; then
        # light mode
        for i in $(eval echo "{$light_start_line_number..$light_end_line_number}")
        do
            # uncomment all lines in light mode colorscheme
            comment_or_uncomment_line 0 $i
        done

        for i in $(eval echo "{$dark_start_line_number..$dark_end_line_number}")
        do
            # comment out all lines in dark mode colorscheme
            comment_or_uncomment_line 1 $i
        done
    else
        # dark mode
        for i in $(eval echo "{$light_start_line_number..$light_end_line_number}")
        do
            # comment out all lines in light mode colorscheme
            comment_or_uncomment_line 1 $i
        done

        for i in $(eval echo "{$dark_start_line_number..$dark_end_line_number}")
        do
            # uncomment all lines in dark mode colorscheme
            comment_or_uncomment_line 0 $i
        done
    fi
}

# start here
ALACRITTY_LIGHT_THEME_NAME=atom_one_light
ALACRITTY_DARK_THEME_NAME=tokyo-night
# ALACRITTY_DARK_THEME_NAME=citylights

grep -rn -E "set background=dark" $HOME/.config/nvim/init.vim
if [ "$?" -eq 0 ]; then
    # light theme
    sed -i "s/set background=dark/set background=light/" $HOME/.config/nvim/init.vim;
    sed -i "s/$ALACRITTY_DARK_THEME_NAME/$ALACRITTY_LIGHT_THEME_NAME/" $HOME/.config/alacritty/alacritty.yml;
    sed -i "s/ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE='fg=#626262'/ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE='fg=#cecece'/" $HOME/.zshrc
    sed -i "s/lightTheme: false/lightTheme: true/" $HOME/.config/jesseduffield/lazygit/config.yml
    sed -i "s/colorscheme molokai/colorscheme github/" $HOME/.vimrc
    toggle_tmux_colorscheme 1;
else
    # dark theme
    sed -i "s/set background=light/set background=dark/" $HOME/.config/nvim/init.vim;
    sed -i "s/$ALACRITTY_LIGHT_THEME_NAME/$ALACRITTY_DARK_THEME_NAME/" $HOME/.config/alacritty/alacritty.yml;
    sed -i "s/ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE='fg=#cecece'/ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE='fg=#626262'/" $HOME/.zshrc
    sed -i "s/lightTheme: true/lightTheme: false/" $HOME/.config/jesseduffield/lazygit/config.yml
    sed -i "s/colorscheme github/colorscheme molokai/" $HOME/.vimrc
    toggle_tmux_colorscheme 2;
fi

