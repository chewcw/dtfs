# syntax = docker/dockerfile:1.4.0
FROM debian:trixie-slim

RUN apt update && apt install -y wget curl sudo git ripgrep xclip xsel build-essential python3 python3 tar unzip ncurses-bin vim pip zsh

# fish shell
# RUN echo 'deb http://download.opensuse.org/repositories/shells:/fish:/release:/3/Debian_11/ /' | tee /etc/apt/sources.list.d/shells:fish:release:3.list && \
#     curl -fsSL https://download.opensuse.org/repositories/shells:fish:release:3/Debian_11/Release.key | gpg --dearmor | tee /etc/apt/trusted.gpg.d/shells_fish_release_3.gpg > /dev/null && \
#     apt update && \
#     apt install -y fish && \
#     chsh --shell $(which fish) ccw

# add new user and add to sudo group
RUN <<EOF
useradd --create-home --shell /usr/bin/zsh ccw;
usermod -aG sudo ccw;
EOF

# so that ccw can use sudo command
RUN passwd --delete ccw
USER ccw

# fzf
RUN <<EOF
git clone --depth 1 https://github.com/junegunn/fzf.git $HOME/.fzf
sh -c "$HOME/.fzf/install --no-update-rc --completion --key-bindings"
EOF

# bash
RUN <<EOF
echo "" >> /home/ccw/.bashrc;
echo 'set -o vi' >> /home/ccw/.bashrc;
EOF

# oh-my-zsh
RUN <<EOF
sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended;
git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins/zsh-autosuggestions || true;
EOF

ARG TARGETARCH

# install development tooling and runtime ------------------------------------------ 
RUN <<EOF
`# dotnet v8.0`
cd /tmp;
wget https://dot.net/v1/dotnet-install.sh -O dotnet-install.sh;
sudo chmod +x dotnet-install.sh;
./dotnet-install.sh --channel 8.0;
rm -rf /tmp/dotnet-install.sh;
sudo ln -s $HOME/.dotnet/dotnet /usr/local/bin/dotnet;
`# https://learn.microsoft.com/en-us/dotnet/core/install/linux-debian#dependencies`
sudo apt install -y libicu72;

`# golang 1.22.1`
sudo mkdir -p /usr/local/go;
wget "https://go.dev/dl/go1.22.1.linux-${TARGETARCH}.tar.gz" -O "/tmp/go1.22.1.linux-${TARGETARCH}.tar.gz";
sudo tar -xzf "/tmp/go1.22.1.linux-${TARGETARCH}.tar.gz" -C /usr/local;
rm -rf "/tmp/go1.22.1.linux-${TARGETARCH}.tar.gz";
sudo ln -s /usr/local/go/bin/go /usr/local/bin/go;

`# FNM (Fast Node Manager)`
curl -fsSL https://fnm.vercel.app/install | bash 

`# rust`
curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y;
ls $HOME/.cargo/bin | awk '{print "/home/ccw/.cargo/bin/"$0}' | xargs sudo ln -s -t /usr/local/bin
EOF

# install firefox
RUN sudo apt install -y firefox-esr

# xdg-utils
RUN <<EOF
sudo apt install -y xdg-utils
`# set default web browser`
xdg-settings set default-web-browser firefox-esr.desktop
EOF

# neovim
RUN <<EOF
`# install neovim`
/bin/bash -c "if [[ $TARGETARCH == "amd64" ]]; then
    curl https://raw.githubusercontent.com/chewcw/dtfs/main/install-nvim.sh | bash;
  else
    cd /tmp; git clone https://github.com/chewcw/nv-built-aarch64; sudo mv nv-built-aarch64/nvim /usr/local;
  fi"
`# symlink for neovim`
sudo ln -sf /usr/local/nvim/bin/nvim /usr/bin/nvim
EOF

# install vscode
RUN <<EOF
ARCH=$([ "$TARGETARCH" = "amd64" ] && echo "x64" || echo "arm64" )
wget "https://code.visualstudio.com/sha/download?build=stable&os=linux-deb-$ARCH" -O /tmp/code.deb;
sudo dpkg -i /tmp/code.deb;
EOF

# cleanup
RUN <<EOF
rm -rf /tmp/*
sudo apt autoremove --yes
sudo rm -rf /var/lib/apt/lists/*
sudo apt update
EOF

WORKDIR /workspace

# use vi mode in fish shell
# RUN mkdir -p $HOME/.config/fish && touch $HOME/.config/fish/config.fish && \
# cat <<EOF >> $HOME/.config/fish/config.fish
# fish_vi_key_bindings
# EOF

# install alacritty terminfo so that neovim can show undercurl
RUN wget https://github.com/alacritty/alacritty/releases/download/v0.12.0/alacritty.info -O /tmp/alacritty.info && \
    sudo tic -xe alacritty,alacritty-direct /tmp/alacritty.info && \
    rm -rf /tmp/alacritty.info

# zshrc
RUN <<EOF cat > /home/ccw/.zshrc
export ZSH="\$HOME/.oh-my-zsh"
ZSH_THEME="af-magic"
DISABLE_AUTO_UPDATE="true"
plugins=(git vi-mode zsh-autosuggestions)
source \$ZSH/oh-my-zsh.sh
[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh
export FZF_DEFAULT_COMMAND="find -L"
export FZF_ALT_C_COMMAND="find ."
export FZF_CTRL_T_COMMAND="\$FZF_DEFAULT_COMMAND"
export FZF_COMPLETION_TRIGGER=','
export ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE='fg=#626262'
export VI_MODE_SET_CURSOR=false
function zle-line-init zle-keymap-select {
    RPS1="\${\${KEYMAP/vicmd/-- NORMAL --}/(main|viins)/}"
    RPS2=\$RPS1
    zle reset-prompt
}
zle -N zle-line-init
zle -N zle-keymap-select
export EDITOR=nvim
export VISUAL=nvim
zmodload zsh/complist
bindkey -M menuselect 'h' vi-backward-char
bindkey -M menuselect 'k' vi-up-line-or-history
bindkey -M menuselect 'l' vi-forward-char
bindkey -M menuselect 'j' vi-down-line-or-history
export LS_COLORS="di=1;36:ln=35:so=32:pi=33:ex=31:bd=34;46:cd=34;43:su=30;41:sg=30;46:tw=30;42:ow=30;43"
zstyle ':completion:*:default' list-colors \${(s.:.)LS_COLORS}
export PATH=\$PATH:/usr/local/go/bin
export PATH=\$PATH:\$HOME/.local/bin
export PATH=\$PATH:\$HOME/.local/share/fnm
eval "\$(fnm env)"
EOF

# this env is necessary for neovim undercurl to work
ENV TERM=
# this env is necessary for neovim xclip integration to work, and also to share the
# host's display, for example the browser in the container will be opened in host's env
ENV DISPLAY=

RUN <<EOF
`# install Lazy.nvim and plugins`
nvim &>/dev/null &
sleep 15s;
EOF

RUN <<EOF
`# install LSP related`
nvim --headless -c 'MasonInstallAll' -c q &>/dev/null &
sleep 1m;
EOF

COPY .gitconfig /home/ccw/.gitconfig
COPY .codeium /home/ccw/
COPY .local/dev/entrypoint.sh /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]
