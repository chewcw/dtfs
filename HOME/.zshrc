# Enable Powerlevel10k instant prompt. Should stay close to the top of ~/.zshrc.
# Initialization code that may require console input (password prompts, [y/n]
# confirmations, etc.) must go above this block; everything else may go below.
# if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
#   source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
# fi

# If you come from bash you might have to change your $PATH.
# export PATH=$HOME/bin:/usr/local/bin:$PATH
# Path to your oh-my-zsh installation.
export ZSH="$HOME/.oh-my-zsh"

# Set name of the theme to load --- if set to "random", it will
# load a random theme each time oh-my-zsh is loaded, in which case,
# to know which specific one was loaded, run: echo $RANDOM_THEME
# See https://github.com/ohmyzsh/ohmyzsh/wiki/Themes
# ZSH_THEME="powerlevel10k/powerlevel10k"
ZSH_THEME="robbyrussell"

# Set list of themes to pick from when loading at random
# Setting this variable when ZSH_THEME=random will cause zsh to load
# a theme from this variable instead of looking in $ZSH/themes/
# If set to an empty array, this variable will have no effect.
# ZSH_THEME_RANDOM_CANDIDATES=( "robbyrussell" "agnoster" )

# Uncomment the following line to use case-sensitive completion.
# CASE_SENSITIVE="true"

# Uncomment the following line to use hyphen-insensitive completion.
# Case-sensitive completion must be off. _ and - will be interchangeable.
# HYPHEN_INSENSITIVE="true"

# Uncomment the following line to disable bi-weekly auto-update checks.
DISABLE_AUTO_UPDATE="true"

# Uncomment the following line to automatically update without prompting.
# DISABLE_UPDATE_PROMPT="true"

# Uncomment the following line to change how often to auto-update (in days).
# export UPDATE_ZSH_DAYS=13

# Uncomment the following line if pasting URLs and other text is messed up.
# DISABLE_MAGIC_FUNCTIONS="true"

# Uncomment the following line to disable colors in ls.
# DISABLE_LS_COLORS="true"

# Uncomment the following line to disable auto-setting terminal title.
# DISABLE_AUTO_TITLE="true"

# Uncomment the following line to enable command auto-correction.
# ENABLE_CORRECTION="true"

# Uncomment the following line to display red dots whilst waiting for completion.
# COMPLETION_WAITING_DOTS="true"

# Uncomment the following line if you want to disable marking untracked files
# under VCS as dirty. This makes repository status check for large repositories
# much, much faster.
# DISABLE_UNTRACKED_FILES_DIRTY="true"

# Uncomment the following line if you want to change the command execution time
# stamp shown in the history command output.
# You can set one of the optional three formats:
# "mm/dd/yyyy"|"dd.mm.yyyy"|"yyyy-mm-dd"
# or set a custom format using the strftime function format specifications,
# see 'man strftime' for details.
# HIST_STAMPS="mm/dd/yyyy"

# Would you like to use another custom folder than $ZSH/custom?
# ZSH_CUSTOM=/path/to/new-custom-folder

# Which plugins would you like to load?
# Standard plugins can be found in $ZSH/plugins/
# Custom plugins may be added to $ZSH_CUSTOM/plugins/
# Example format: plugins=(rails git textmate ruby lighthouse)
# Add wisely, as too many plugins slow down shell startup.
plugins=(
  git
  vi-mode
  zsh-autosuggestions
)

source $ZSH/oh-my-zsh.sh

# User configuration

# export MANPATH="/usr/local/man:$MANPATH"

# You may need to manually set your language environment
# export LANG=en_US.UTF-8

# Preferred editor for local and remote sessions
# if [[ -n $SSH_CONNECTION ]]; then
#   export EDITOR='vim'
# else
#   export EDITOR='mvim'
# fi

# Compilation flags
# export ARCHFLAGS="-arch x86_64"

# Set personal aliases, overriding those provided by oh-my-zsh libs,
# plugins, and themes. Aliases can be placed here, though oh-my-zsh
# users are encouraged to define aliases within the ZSH_CUSTOM folder.
# For a full list of active aliases, run `alias`.
#
# Example aliases
# alias zshconfig="mate ~/.zshrc"
# alias ohmyzsh="mate ~/.oh-my-zsh"
# export PATH=$HOME/go/bin:$PATH
# export PATH=$PATH:$HOME/.cargo/bin

# ZSH_AUTOSUGGEST text color
# this can be changed by colorscheme switcher
# see $HOME/.local/bin/toggle-colorscheme.sh
export ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE='fg=#626262'
export VI_MODE_SET_CURSOR=false

# https://unix.stackexchange.com/a/1019
function zle-line-init zle-keymap-select {
    RPS1="${${KEYMAP/vicmd/-- NORMAL --}/(main|viins)/}"
    RPS2=$RPS1
    zle reset-prompt
}
zle -N zle-line-init
zle -N zle-keymap-select

export EDITOR=nvim
export VISUAL=nvim

alias c="code -r"
alias dc="docker-compose"
alias darm="docker run --rm --privileged multiarch/qemu-user-static --reset -p yes --credential yes"
alias lg="lazygit"
alias gforeachref="git for-each-ref --sort=committerdate --format '%(refname) on %(color:bold blue)%(committerdate) %(color:bold white) by %(color:green) %(committername)%(committeremail)'"

# Use hjkl to navigate zsh completion menu
# https://thevaluable.dev/zsh-install-configure-mouseless/
zmodload zsh/complist
bindkey -M menuselect 'h' vi-backward-char
bindkey -M menuselect 'k' vi-up-line-or-history
bindkey -M menuselect 'l' vi-forward-char
bindkey -M menuselect 'j' vi-down-line-or-history

# Jump to parent directory easily
# https://thevaluable.dev/zsh-install-configure-mouseless/
# source $HOME/zsh/plugins/bd.zsh

# keyboard repeat delay
xset r rate 300 70
# language input
fcitx &>/dev/null

# open control panel in i3
alias gnome-control-center="env XDB_CURRENT_DESKOP=GNOME gnome-control-center"

# kubectl
export PATH=$PATH:$HOME/.local/bin/kubectl/
alias k=kubectl

# powerlevel10k
# To customize prompt, run `p10k configure` or edit ~/.p10k.zsh.
# [[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh

# bluetooth connect
alias g6="bluetoothctl connect 00:21:13:00:A9:43"
alias rb="bluetoothctl connect 20:00:31:19:9A:54"
alias mouse="bluetoothctl connect 34:88:5D:3E:B8:DE"

# fzf
[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh
export FZF_DEFAULT_COMMAND="find -L"
export FZF_ALT_C_COMMAND="find ."
export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
export FZF_COMPLETION_TRIGGER=','

# zsh-vi-mode
# zvm_after_init_commands+=('[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh')

# directory's permission color
# https://askubuntu.com/questions/881949/ugly-color-for-directories-in-gnome-terminal
# https://github.com/ohmyzsh/ohmyzsh/issues/6060
export LS_COLORS="di=1;36:ln=35:so=32:pi=33:ex=31:bd=34;46:cd=34;43:su=30;41:sg=30;46:tw=30;42:ow=30;43"
# colorize completions using default `ls` colors
zstyle ':completion:*:default' list-colors ${(s.:.)LS_COLORS}

# Connect to maple home monitor correctly
alias monitor-maple="xrandr --auto && xrandr --output DP-2 --left-of HDMI-1"
alias monitor-home="xrandr --auto && xrandr --output DP-2 --right-of eDP-1"
alias monitor="xrandr --auto"

# tmux and zsh auto-suggestion color issue
# https://github.com/zsh-users/zsh-autosuggestions/issues/229
export TERM=xterm-256color

# watch
alias watch="watch "

# fff
# export FFF_FAV1=/home/ccw/Documents/
# export FFF_HIDDEN=1
# export FFF_COL2=0
# export FFF_COL5=2
# alias f=$HOME/.fff/fff

# specific to LXQT lubuntu
export XCURSOR_SIZE=35
alias audio=pavucontrol-qt
alias network=nm-connection-editor

export PATH=$PATH:/usr/local/go/bin
export PATH=$PATH:$HOME/.local/bin

# stdout to clipboard
# https://stackoverflow.com/questions/5130968/how-can-i-copy-the-output-of-a-command-directly-into-my-clipboard
alias xc="xclip -selection clipboard"
alias xs="xsel --append --clipboard"

alias gnome-control-center="env XDG_CURRENT_DESKTOP=GNOME gnome-control-center";
export XDG_CURRENT_DESKTOP=GNOME;

export POWERLEVEL9K_DISABLE_CONFIGURATION_WIZARD=true

alias monitor=arandr
alias img=eog

# Prevent ghost character showing in the shell
# https://serverfault.com/a/894545
export LC_ALL=en_US.UTF-8
export LANG=en_US.UTF-8
export LANGUAGE=en_US.UTF-8

# edit command in the text editor
# https://unix.stackexchange.com/a/90529
export VISUAL=nvim
autoload edit-command-line; zle -N edit-command-line
bindkey -M vicmd z edit-command-line

# yazi
function y() {
  local tmp="$(mktemp -t "yazi-cwd.XXXXX")"
  yazi "$@" --cwd-file="$tmp"
  if cwd="$(cat -- "$tmp")" && [ -n "$cwd" ] && [ "$cwd" != "$PWD" ]; then
    cd -- "$cwd"
  fi
  rm -f -- "$tmp"
}
