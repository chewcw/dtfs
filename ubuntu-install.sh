#!/usr/bin/env bash

set -e

pwd=`pwd` whoami=`whoami`


# determining debian or ubuntu
uname -a | grep Debian &>/dev/null
if [[ $? -eq 0 ]]; then
	distro=debian
	distro_version=11
else
	uname -a | grep Ubuntu &>/dev/null
	if [[ $? -eq 0 ]]; then
	       distro=ubuntu
	       distro_version=22.04
	fi
fi

if [[ -z $distro || -z $distro_version ]]; then
	echo "Invalid distro=$distro or distro_version=$distro_version"
	exit -1
else
	echo "------------------------------------------"
	echo "Distro is $distro, version is $distro_version"
	echo "------------------------------------------"
fi

sleep 3

# start
sudo apt-get update
sudo apt-get install -y apt-transport-https curl

# Create config directory
mkdir -p $HOME/.config

# Install git
echo "------------------------------------------"
echo "Installing git"
echo "------------------------------------------"
sudo apt install -y git

# Install lazygit v0.40.2
if ! command -v lazygit &>/dev/null
then
	echo "------------------------------------------"
	echo "Installing lazygit"
	echo "------------------------------------------"
	lazygit_tar_name=lazygit_0.40.2_Linux_x86_64.tar
	rm -rf /tmp/$lazygit_tar_name
	wget https://github.com/jesseduffield/lazygit/releases/download/v0.40.2/$lazygit_tar_name.gz -O /tmp/$lazygit_tar_name.gz
	gzip -d /tmp/$lazygit_tar_name.gz
	tar xvf /tmp/$lazygit_tar_name --directory=/tmp
	sudo mv /tmp/lazygit /usr/local/bin/lazygit
fi
# Setup lazygit
echo "------------------------------------------"
echo "Setting up lazygit"
echo "------------------------------------------"
mkdir -p $HOME/.config/jesseduffield
mkdir -p $HOME/.config/jesseduffield/lazygit
ln -sf $pwd/HOME/.config/jesseduffield/lazygit/config.yml $HOME/.config/jesseduffield/lazygit/config.yml

# Install font (Iosevka-SS14)
echo "------------------------------------------"
echo "Installing iosevka fonts"
echo "------------------------------------------"
mkdir -p $HOME/.fonts
cp $pwd/custom-fonts/Iosevka-nerdfont-patched/* $HOME/.fonts || true

# Install gnome-vim
# Use vim-gtk3 so that I have +xterm_clipboard support
echo "------------------------------------------"
echo "Installing gnome-vim"
echo "------------------------------------------"
sudo apt install -y vim-gtk3

# Install fzf
echo "------------------------------------------"
echo "Installing fzf"
echo "------------------------------------------"
git clone --depth 1 https://github.com/junegunn/fzf.git $HOME/.fzf || true
$HOME/.fzf/install --no-update-rc --completion --key-bindings

# Install xsel (I think it's better than xclip)
echo "------------------------------------------"
echo "Installing xsel"
echo "------------------------------------------"
sudo apt install xsel -y

# Install fff
if [[ ! -d "$HOME/.fff" ]]; then
	echo "------------------------------------------"
	echo "Installing fff"
	echo "------------------------------------------"
	git clone https://github.com/dylanaraps/fff $HOME/.fff || true
	sudo make -k -C $HOME/.fff install || true
fi

# Install mapping caps to ctrl (or remapping capslock to escape AND ctrl)
echo "------------------------------------------"
echo "Installing interception tools and caps2esc"
echo "------------------------------------------"
# when press caps alone, send escape
# when press caps with another key, send ctrl
# caps2esc
# see: https://gitlab.com/interception/linux/plugins/caps2esc
# by default wihout any configuration this will swap capslock and escape
# sudo add-apt-repository ppa:deafmute/interception
# all docs I see online are using `intercept`, but in debian,
# somehow the command is called `interception`

sudo apt install -y interception-tools
sudo apt install -y interception-caps2esc

sudo bash -c 'cat << EOF > /etc/interception/udevmon.yaml
- JOB: "interception -g \$DEVNODE | caps2esc -m 0 | uinput -d \$DEVNODE"
  DEVICE:
      EVENTS:
        EV_KEY: [KEY_CAPSLOCK, KEY_ESC]
EOF'

sudo systemctl restart udevmon

# TODO: which one is better? xcape or caps2esc?
# see: https://askubuntu.com/a/856887
# sudo apt install -y xcape
# setxkbmap -option caps:ctrl_modifier
# or just map caps to ctrl, if using above method, sometimes when press caps
# then somehow I want to cancel the action, but it turns out escape was 
# registered, so maybe it's better to separate the escape and control function.

# Setup neovim
# Install symlink for .vimrc
echo "------------------------------------------"
echo "Setting up vimrc"
echo "------------------------------------------"
ln -sf $pwd/HOME/.vimrc $HOME/.vimrc
# Install symlink for .gvimrc
echo "------------------------------------------"
echo "Setting up gvimrc"
echo "------------------------------------------"
ln -sf $pwd/HOME/.gvimrc $HOME/.gvimrc
mkdir -p $HOME/.vim
mkdir -p $HOME/.vim/colors
ln -sf $pwd/HOME/.vim/colors/github.vim $HOME/.vim/colors/github.vim

# Install Neovim (v0.9.1)
echo "------------------------------------------"
echo "Installing Neovim (v0.9.1)"
echo "------------------------------------------"
./install-nvim.sh
ln -sf $pwd/HOME/.config/nvim $HOME/.config/nvim

# Install i3
echo "------------------------------------------"
echo "Installing i3wm"
echo "------------------------------------------"
sudo apt install -y i3-wm i3

# Install i3-gaps
# sudo add-apt-repository -y ppa:regolith-linux/release
# sudo apt update
# sudo apt install -y i3-gaps

# Install i3status config
echo "------------------------------------------"
echo "Installing i3status"
echo "------------------------------------------"
sudo apt install -y i3status
# Install symlink for i3status
mkdir -p $HOME/.config/i3status
ln -sf $pwd/HOME/.config/i3status/config $HOME/.config/i3status/config

# Install tmux plugin manager
if [[ ! -d $HOME/.tmux/plugins/tpm ]]; then
	echo "------------------------------------------"
	echo "Installing tmux plugin manager"
	echo "------------------------------------------"
	git clone https://github.com/tmux-plugins/tpm $HOME/.tmux/plugins/tpm || true
fi

# Setup i3
# Install symlink for i3 config
echo "------------------------------------------"
echo "Installing symlink for i3 config"
echo "------------------------------------------"
mkdir -p $HOME/.config/i3
ln -sf $pwd/HOME/.config/i3/config $HOME/.config/i3/config

# Setup dunst (notification daemon)
echo "------------------------------------------"
echo "Installing symlink for dunstrc"
echo "------------------------------------------"
sudo mkdir -p /etc/xdg
sudo mkdir -p /etc/xdg/dunst
sudo ln -sf $pwd/etc/xdg/dunst/dunstrc /etc/xdg/dunst/dunstrc

# Install tmux terminal multiplexer
if ! command -v tmux &>/dev/null
then
	echo "------------------------------------------"
	echo "Installing tmux"
	echo "------------------------------------------"
	sudo apt install -y tmux
	tmux_file_name=tmux_3.1c-1+deb11u1_amd64.deb
	rm -rf /tmp/$tmux_file_name
	wget http://ftp.us.debian.org/debian/pool/main/t/tmux/$tmux_file_name -O /tmp/$tmux_file_name || true
	sudo dpkg --install /tmp/$tmux_file_name
	rm -rf /tmp/$tmux_file_name
fi
# Install symlink for tmux.conf
mkdir -p $HOME/.config/tmux
ln -sf $pwd/HOME/.config/tmux/tmux.conf $HOME/.config/tmux/tmux.conf

# Install alacritty terminal emulator
if ! command -v alacritty &>/dev/null
then
	echo "------------------------------------------"
	echo "Installing alacritty"
	echo "------------------------------------------"
	alacritty_file_name=alacritty_0.12.0_amd64_bullseye.deb
	rm -rf /tmp/$alacritty_file_name
	wget https://github.com/barnumbirr/alacritty-debian/releases/download/v0.12.0-1/$alacritty_file_name -O /tmp/$alacritty_file_name
	sudo dpkg -i /tmp/$alacritty_file_name
	rm -rf /tmp/$alacritty_file_name
fi
# Install symlink for alacritty.yml
mkdir -p $HOME/.config/alacritty
ln -sf $pwd/HOME/.config/alacritty/alacritty.yml $HOME/.config/alacritty/alacritty.yml

# alacritty color theme
# mkdir -p ~/.config/alacritty/themes
# git clone https://github.com/alacritty/alacritty-theme ~/.config/alacritty/themes
# Install symlink for colorscheme switcher
# ln -sf $pwd/HOME/.local/bin/toggle-colorscheme.sh $HOME/.local/bin/toggle-colorscheme.sh

# Install symlink for docker development script
echo "------------------------------------------"
echo "Installing symlink for docker development script"
echo "------------------------------------------"
mkdir -p $HOME/.local
mkdir -p $HOME/.local/bin
ln -sf $pwd/HOME/.local/bin/dev.sh $HOME/.local/bin/dev.sh

# Install symlink for connect monitor
echo "------------------------------------------"
echo "Installing symlink for connection_monitor"
echo "------------------------------------------"
ln -sf $pwd/HOME/.local/bin/connect_monitor.sh $HOME/.local/bin/connect_monitor.sh

# Install vscodium
if ! command -v codium &>/dev/null
then
	echo "------------------------------------------"
	echo "Installing vscodium"
	echo "------------------------------------------"
	codium_file_name=codium_1.81.1.23222_amd64.deb
	rm -rf /tmp/$codium_file_name
	wget https://github.com/VSCodium/vscodium/releases/download/1.81.1.23222/$codium_file_name -O /tmp/$codium_file_name
	sudo dpkg --install /tmp/$codium_file_name || true
	rm -rf /tmp/$codium_file_name
fi

# Install Brave browser
# sudo curl -fsSLo /usr/share/keyrings/brave-browser-archive-keyring.gpg https://brave-browser-apt-release.s3.brave.com/brave-browser-archive-keyring.gpg
# echo "deb [signed-by=/usr/share/keyrings/brave-browser-archive-keyring.gpg arch=amd64] https://brave-browser-apt-release.s3.brave.com/ stable main"|sudo tee /etc/apt/sources.list.d/brave-browser-release.list
# sudo apt update
# sudo apt install -y brave-browser

# Install docker
if ! command -v docker &>/dev/null
then
	echo "------------------------------------------"
	echo "Installing docker for $distro"
	echo "------------------------------------------"
	sudo apt update
	sudo apt install -y \
		ca-certificates \
		gnupg-agent \
		software-properties-common
	sudo install -m 0755 -d /etc/apt/keyrings
	curl -fsSL https://download.docker.com/linux/$distro/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
	sudo chmod a+r /etc/apt/keyrings/docker.gpg
	echo \
	  "deb [arch="$(dpkg --print-architecture)" signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/$distro \
	  "$(. /etc/os-release && echo "$VERSION_CODENAME")" stable" | \
	  sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
	sudo apt update
	sudo apt install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin -y
	sudo usermod -aG docker $whoami
fi

# Enable docker experimental mode
echo "------------------------------------------"
echo "Enable docker experimental mode"
echo "------------------------------------------"
mkdir -p $HOME/.docker
echo { \"experimental\" : \"enabled\" } > $HOME/.docker/config.json

# Install vlc
echo "------------------------------------------"
echo "Installing vlc"
echo "------------------------------------------"
sudo apt install -y vlc

# Install Audio controls 
echo "------------------------------------------"
echo "Installing audio controls"
echo "------------------------------------------"
sudo apt install -y alsa-utils pulseaudio || true

# Install brightness controls
echo "------------------------------------------"
echo "Installing brightness controls"
echo "------------------------------------------"
sudo apt install -y brightnessctl || true

# Install flameshot
# https://github.com/flameshot-org/flameshot
if ! command -v flameshot &>/dev/null
then
	echo "------------------------------------------"
	echo "Installing flameshot"
	echo "------------------------------------------"
	flameshot_file_name=flameshot-12.1.0-1.$distro-$distro_version.amd64.deb
	wget "https://github.com/flameshot-org/flameshot/releases/download/v12.1.0/$flameshot_file_name" -O /tmp/$flameshot_file_name  || true
	sudo dpkg -i /tmp/$flameshot_file_name || true
	mkdir -p $HOME/.config/Dharkael && ln -sf $pwd/HOME/.config/flameshot/flameshot.conf $HOME/.config/Dharkael/flameshot.conf
fi

# Install feh for desktop background
echo "------------------------------------------"
echo "Installing feh"
echo "------------------------------------------"
sudo apt install -y feh

# Install barrier
# https://github.com/debauchee/barrier#distro-specific-packages
echo "------------------------------------------"
echo "Installing barrier"
echo "------------------------------------------"
sudo apt install -y barrier

# Install compton
# sudo apt install -y compton
# Install symlink for compton
# mkdir -p $HOME/.config/compton
# ln -sf $pwd/HOME/.config/compton/compton.conf $HOME/.config/compton/compton.conf

# sz (https://github.com/Zarfir/Screenz)
# chmod +x $pwd/HOME/sz
# sudo ln -sf $pwd/HOME/sz /usr/local/bin/sz

# lxrandr
echo "------------------------------------------"
echo "Installing xdotool and lxrandr"
echo "------------------------------------------"
sudo apt install -y xdotool lxrandr

# X11 configuration using libinput as input driver
echo "------------------------------------------"
echo "X11 configuration using libinput"
echo "------------------------------------------"
# from https://cravencode.com/post/essentials/enable-tap-to-click-in-i3wm/
# from https://unix.stackexchange.com/questions/567974/how-to-make-3-finger-tap-on-touchpad-act-as-middle-mouse-button-for-debian-10-c
# how do I configure my device on X: https://wayland.freedesktop.org/libinput/doc/latest/faqs.html#how-do-i-configure-my-device-on-x
# see libinput configuration option: https://www.mankier.com/4/libinput
sudo mkdir -p /etc/X11/xorg.conf.d && sudo tee <<'EOF' /etc/X11/xorg.conf.d/90-touchpad.conf 1> /dev/null
Section "InputClass"
        Identifier "touchpad"
        MatchIsTouchpad "on"
        Driver "libinput"
        Option "Tapping" "on"
        Option "TappingButtonMap" "lrm" # three finger tap is middle click
        Option "AccelSpeed" "+0.7" # touchpad acceleration
EndSection

EOF


# shell setup
# ------------------------------ put below in the end

# Install zsh
echo "------------------------------------------"
echo "Installing zsh"
echo "------------------------------------------"
sudo apt install -y zsh

# Setup oh-my-zsh and Powerlevel10k
if [[ -d $HOME/.oh-my-zsh ]]; then
	rm -rf $HOME/.oh-my-zsh
fi
echo "------------------------------------------"
echo "Installing oh-my-zsh"
echo "------------------------------------------"
# sh -c "$(curl -fsSL https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" || true
curl -fsSL https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh | bash

#if [[ ! -d $HOME/.oh-my-zsh/custom/themes/powerlevel10k ]]; then
#	echo "------------------------------------------"
#	echo "Installing powerlevel10k"
#	echo "------------------------------------------"
#	git clone --depth=1 https://github.com/romkatv/powerlevel10k.git ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/powerlevel10k || true
#fi

# install zsh-autosuggestion
if [[ ! -d $HOME/.oh-my-zsh/custom/plugins/zsh-autosuggestions ]]; then
	echo "------------------------------------------"
	echo "Installing zsh-autosuggestion"
	echo "------------------------------------------"
	git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins/zsh-autosuggestions || true
fi

# install zsh-vi-mode
# git clone https://github.com/jeffreytse/zsh-vi-mode ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins/zsh-vi-mode || true

# Install symlink for .zshrc
echo "------------------------------------------"
echo "Installing symlink for .zshrc"
echo "------------------------------------------"
ln -sf $pwd/HOME/.zshrc $HOME/.zshrc

# zsh plugin
# bd (jump to parent directory easily)
# mkdir -p $HOME/zsh/plugins || true
# ln -sf $pwd/HOME/zsh/plugins/bd.zsh $HOME/zsh/plugins/bd.zsh

# done
echo "=========================================="
echo "Setup done......"
echo "=========================================="

