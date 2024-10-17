# syntax = docker/dockerfile:1.4.0
FROM debian:trixie-slim

RUN apt update && apt install -y wget curl sudo git ripgrep xclip xsel build-essential python3 python3 tar unzip ncurses-bin vim pip zsh file

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
./dotnet-install.sh --channel 8.0 --azure-feed --install-dir=$HOME/.dotnet;
rm -rf /tmp/dotnet-install.sh;
sudo ln -s $HOME/.dotnet/dotnet /usr/local/bin/dotnet;
`# https://learn.microsoft.com/en-us/dotnet/core/install/linux-debian#dependencies`
sudo apt install -y libicu72;

`# golang 1.23.1`
sudo mkdir -p /usr/local/go;
wget "https://go.dev/dl/go1.23.1.linux-${TARGETARCH}.tar.gz" -O "/tmp/go1.23.1.linux-${TARGETARCH}.tar.gz";
sudo tar -xzf "/tmp/go1.23.1.linux-${TARGETARCH}.tar.gz" -C /usr/local;
rm -rf "/tmp/go1.23.1.linux-${TARGETARCH}.tar.gz";
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
EOF

USER root

# install vscode
RUN <<EOF
`# Install vscode`
apt update
apt install gpg -y
wget -qO- https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor > /etc/apt/trusted.gpg.d/packages.microsoft.gpg
ls -lah /etc/apt/trusted.gpg.d/
sh -c 'echo "deb [arch=amd64] https://packages.microsoft.com/repos/vscode stable main" > /etc/apt/sources.list.d/vscode.list'
apt update
apt install code -y
EOF

USER ccw

# cleanup
RUN <<EOF
rm -rf /tmp/*
sudo apt autoremove --yes
sudo rm -rf /var/lib/apt/lists/*
sudo apt update
EOF

# update locale
RUN <<EOF
sudo apt-get update
sudo apt-get install -y locales
sed -i 's/^# *\(en_US.UTF-8\)/\1/' /etc/locale.gen
sudo locale-gen
EOF

WORKDIR /workspace

# use vi mode in fish shell
# RUN mkdir -p $HOME/.config/fish && touch $HOME/.config/fish/config.fish && \
# cat <<EOF >> $HOME/.config/fish/config.fish
# fish_vi_key_bindings
# EOF

# install alacritty terminfo so that neovim can show undercurl
# RUN wget https://github.com/alacritty/alacritty/releases/download/v0.12.0/alacritty.info -O /tmp/alacritty.info && \
#     sudo tic -xe alacritty,alacritty-direct /tmp/alacritty.info && \
#     rm -rf /tmp/alacritty.info

# install kitty terminfo
RUN <<EOF cat >/tmp/kitty.info
xterm-kitty|KovIdTTY,
	am, ccc, hs, km, mc5i, mir, msgr, npc, xenl, Su, Tc, fullkbd,
	colors#0x100, cols#80, it#8, lines#24, pairs#0x7fff,
	acsc=++\,\,--..00``aaffgghhiijjkkllmmnnooppqqrrssttuuvvwwxxyyzz{{||}}~~,
	bel=^G, bold=\E[1m, cbt=\E[Z, civis=\E[?25l,
	clear=\E[H\E[2J, cnorm=\E[?12h\E[?25h, cr=\r,
	csr=\E[%i%p1%d;%p2%dr, cub=\E[%p1%dD, cub1=^H,
	cud=\E[%p1%dB, cud1=\n, cuf=\E[%p1%dC, cuf1=\E[C,
	cup=\E[%i%p1%d;%p2%dH, cuu=\E[%p1%dA, cuu1=\E[A,
	cvvis=\E[?12;25h, dch=\E[%p1%dP, dch1=\E[P, dim=\E[2m,
	dl=\E[%p1%dM, dl1=\E[M, dsl=\E]2;\007, ech=\E[%p1%dX,
	ed=\E[J, el=\E[K, el1=\E[1K, flash=\E[?5h$<100/>\E[?5l,
	fsl=^G, home=\E[H, hpa=\E[%i%p1%dG, ht=^I, hts=\EH,
	ich=\E[%p1%d@, il=\E[%p1%dL, il1=\E[L, ind=\n,
	indn=\E[%p1%dS,
	initc=\E]4;%p1%d;rgb:%p2%{255}%*%{1000}%/%2.2X/%p3%{255}%*%{1000}%/%2.2X/%p4%{255}%*%{1000}%/%2.2X\E\\,
	kBEG=\E[1;2E, kDC=\E[3;2~, kEND=\E[1;2F, kHOM=\E[1;2H,
	kIC=\E[2;2~, kLFT=\E[1;2D, kNXT=\E[6;2~, kPRV=\E[5;2~,
	kRIT=\E[1;2C, ka1=, ka3=, kbeg=\EOE, kbs=^?, kc1=, kc3=,
	kcbt=\E[Z, kcub1=\EOD, kcud1=\EOB, kcuf1=\EOC, kcuu1=\EOA,
	kdch1=\E[3~, kend=\EOF, kf1=\EOP, kf10=\E[21~, kf11=\E[23~,
	kf12=\E[24~, kf13=\E[1;2P, kf14=\E[1;2Q, kf15=\E[1;2R,
	kf16=\E[1;2S, kf17=\E[15;2~, kf18=\E[17;2~,
	kf19=\E[18;2~, kf2=\EOQ, kf20=\E[19;2~, kf21=\E[20;2~,
	kf22=\E[21;2~, kf23=\E[23;2~, kf24=\E[24;2~,
	kf25=\E[1;5P, kf26=\E[1;5Q, kf27=\E[1;5R, kf28=\E[1;5S,
	kf29=\E[15;5~, kf3=\EOR, kf30=\E[17;5~, kf31=\E[18;5~,
	kf32=\E[19;5~, kf33=\E[20;5~, kf34=\E[21;5~,
	kf35=\E[23;5~, kf36=\E[24;5~, kf37=\E[1;6P, kf38=\E[1;6Q,
	kf39=\E[1;6R, kf4=\EOS, kf40=\E[1;6S, kf41=\E[15;6~,
	kf42=\E[17;6~, kf43=\E[18;6~, kf44=\E[19;6~,
	kf45=\E[20;6~, kf46=\E[21;6~, kf47=\E[23;6~,
	kf48=\E[24;6~, kf49=\E[1;3P, kf5=\E[15~, kf50=\E[1;3Q,
	kf51=\E[1;3R, kf52=\E[1;3S, kf53=\E[15;3~, kf54=\E[17;3~,
	kf55=\E[18;3~, kf56=\E[19;3~, kf57=\E[20;3~,
	kf58=\E[21;3~, kf59=\E[23;3~, kf6=\E[17~, kf60=\E[24;3~,
	kf61=\E[1;4P, kf62=\E[1;4Q, kf63=\E[1;4R, kf7=\E[18~,
	kf8=\E[19~, kf9=\E[20~, khlp=, khome=\EOH, kich1=\E[2~,
	kind=\E[1;2B, kmous=\E[M, knp=\E[6~, kpp=\E[5~,
	kri=\E[1;2A, kund=, oc=\E]104\007, op=\E[39;49m, rc=\E8,
	rep=%p1%c\E[%p2%{1}%-%db, rev=\E[7m, ri=\EM,
	rin=\E[%p1%dT, ritm=\E[23m, rmacs=\E(B, rmam=\E[?7l,
	rmcup=\E[?1049l, rmir=\E[4l, rmkx=\E[?1l, rmso=\E[27m,
	rmul=\E[24m, rs1=\E]\E\\\Ec, sc=\E7,
	setab=\E[%?%p1%{8}%<%t4%p1%d%e%p1%{16}%<%t10%p1%{8}%-%d%e48;5;%p1%d%;m,
	setaf=\E[%?%p1%{8}%<%t3%p1%d%e%p1%{16}%<%t9%p1%{8}%-%d%e38;5;%p1%d%;m,
	sgr=%?%p9%t\E(0%e\E(B%;\E[0%?%p6%t;1%;%?%p2%t;4%;%?%p1%p3%|%t;7%;%?%p4%t;5%;%?%p7%t;8%;m,
	sgr0=\E(B\E[m, sitm=\E[3m, smacs=\E(0, smam=\E[?7h,
	smcup=\E[?1049h, smir=\E[4h, smkx=\E[?1h, smso=\E[7m,
	smul=\E[4m, tbc=\E[3g, tsl=\E]2;, u6=\E[%i%d;%dR, u7=\E[6n,
	u8=\E[?%[;0123456789]c, u9=\E[c, vpa=\E[%i%p1%dd,
	Smulx=\E[4:%p1%dm, Sync=\EP=%p1%ds\E\\, kBEG3=\E[1;3E,
	kBEG4=\E[1;4E, kBEG5=\E[1;5E, kBEG6=\E[1;6E,
	kBEG7=\E[1;7E, kDC3=\E[3;3~, kDC4=\E[3;4~, kDC5=\E[3;5~,
	kDC6=\E[3;6~, kDC7=\E[3;7~, kDN=\E[1;2B, kDN3=\E[1;3B,
	kDN4=\E[1;4B, kDN5=\E[1;5B, kDN6=\E[1;6B, kDN7=\E[1;7B,
	kEND3=\E[1;3F, kEND4=\E[1;4F, kEND5=\E[1;5F,
	kEND6=\E[1;6F, kEND7=\E[1;7F, kHOM3=\E[1;3H,
	kHOM4=\E[1;4H, kHOM5=\E[1;5H, kHOM6=\E[1;6H,
	kHOM7=\E[1;7H, kIC3=\E[2;3~, kIC4=\E[2;4~, kIC5=\E[2;5~,
	kIC6=\E[2;6~, kIC7=\E[2;7~, kLFT3=\E[1;3D, kLFT4=\E[1;4D,
	kLFT5=\E[1;5D, kLFT6=\E[1;6D, kLFT7=\E[1;7D,
	kNXT3=\E[6;3~, kNXT4=\E[6;4~, kNXT5=\E[6;5~,
	kNXT6=\E[6;6~, kNXT7=\E[6;7~, kPRV3=\E[5;3~,
	kPRV4=\E[5;4~, kPRV5=\E[5;5~, kPRV6=\E[5;6~,
	kPRV7=\E[5;7~, kRIT3=\E[1;3C, kRIT4=\E[1;4C,
	kRIT5=\E[1;5C, kRIT6=\E[1;6C, kRIT7=\E[1;7C, kUP=\E[1;2A,
	kUP3=\E[1;3A, kUP4=\E[1;4A, kUP5=\E[1;5A, kUP6=\E[1;6A,
	kUP7=\E[1;7A, rmxx=\E[29m,
	setrgbb=\E[48:2:%p1%d:%p2%d:%p3%dm,
	setrgbf=\E[38:2:%p1%d:%p2%d:%p3%dm, smxx=\E[9m,
EOF
RUN sudo tic -x /tmp/kitty.info 2>/dev/null && rm /tmp/kitty.info

# zshrc
RUN <<EOF cat > /home/ccw/.zshrc
export ZSH="\$HOME/.oh-my-zsh"
ZSH_THEME="avit"
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
export LC_ALL=en_US.UTF-8
export LANG=en_US.UTF-8
export LANGUAGE=en_US.UTF-8
eval "\$(fnm env)"
EOF

USER root
# xdg-open in the /usr/local/bin should take precedence over /usr/bin/xdg-open
# the purpose is to use vim to open link in the background without blocking using
# this xdg-open script
RUN <<EOF cat > /usr/local/bin/xdg-open
#!/bin/sh
/usr/bin/xdg-open "\$@" &
EOF
RUN chmod +x /usr/local/bin/xdg-open

USER ccw

# this env is necessary for neovim undercurl to work
ENV TERM=
# this env is necessary for neovim xclip integration to work, and also to share the
# host's display, for example the browser in the container will be opened in host's env
ENV DISPLAY=

RUN <<EOF
`# install Lazy.nvim and plugins`
nvim &>/dev/null &
sleep 1m;
EOF

RUN <<EOF
`# install LSP related`
nvim --headless -c 'MasonInstallAll' -c q &>/dev/null &
sleep 1m;
EOF

# locales
RUN <<EOF
sudo apt install locales -y
sudo sed -i 's/^# *\(en_US.UTF-8\)/\1/' /etc/locale.gen
sudo locale-gen
EOF

COPY --chown=ccw:ccw .gitconfig /home/ccw/.gitconfig
COPY --chown=ccw:ccw .codeium /home/ccw/.codeium
COPY --chown=ccw:ccw .local/dev/entrypoint.sh /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]
