#!/usr/bin/env bash

set -e

pwd=`pwd` whoami=`whoami`

# Enable AUR support
sudo pacman -S --noconfirm git base-devel
if ! command -v yay &>/dev/null
then
  echo "------------------------------------------"
  echo "Installing yay (AUR helper)"
  echo "------------------------------------------"
  git clone https://aur.archlinux.org/yay.git /tmp/yay || true
  cd /tmp/yay
  makepkg -si --noconfirm || true
  cd -
fi

# start
sudo pacman -Sy

# Create config directory
mkdir -p $HOME/.config

# Create local bin directory
mkdir -p $HOME/.local/bin

# Clone the dtfs
cd $HOME
if [[ ! -d "$HOME/dtfs" ]]; then
  echo "------------------------------------------"
  echo "Cloning dtfs"
  echo "------------------------------------------"
  git clone https://github.com/chewcw/dtfs.git || true
fi
cd $HOME/dtfs

# setup global git config
echo "------------------------------------------"
echo "Setup global git config"
echo "------------------------------------------"
ln -sf $pwd/HOME/.gitconfig $HOME/.gitconfig

# Install mapping caps to ctrl (or remapping capslock to escape AND ctrl)
echo "------------------------------------------"
echo "Installing interception tools and caps2esc"
echo "------------------------------------------"
# when press caps alone, send escape
# when press caps with another key, send ctrl
# caps2esc
# see: https://gitlab.com/interception/linux/plugins/caps2esc
# by default without any configuration this will swap capslock and escape
# sudo add-apt-repository ppa:deafmute/interception
# all docs I see online are using `intercept`, but in debian,
# somehow the command is called `interception`
# ########### updated, the keymap has been modified by myself to suit my needs:
# see: https://gitlab.com/chewcw/caps2esc.git README
# added another 2 special modes:
# mode 3 for normal keyboard, mode 4 for 60% layouts keyboard

sudo bash -c 'cat << EOF > /etc/interception/udevmon.yaml
- JOB: "interception -g \$DEVNODE | caps2esc -m 3 | uinput -d \$DEVNODE"
  DEVICE:
      EVENTS:
        EV_KEY: [KEY_CAPSLOCK, KEY_ESC]
EOF'

sudo systemctl restart udevmon || true

# TODO: which one is better? xcape or caps2esc?
# see: https://askubuntu.com/a/856887
# sudo pacman -S --noconfirm xcape
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
mkdir -p $HOME/.vim
mkdir -p $HOME/.vim/colors
ln -sf $pwd/HOME/.vim/colors/github.vim $HOME/.vim/colors/github.vim

# Install Neovim (v0.10.0)
echo "------------------------------------------"
echo "Installing Neovim (v0.10.0)"
echo "------------------------------------------"
ln -sf $pwd/HOME/.config/nvim $HOME/.config


# ----------------------------------------------------------------------------- 
# Installing some utilities
# ----------------------------------------------------------------------------- 
# echo "------------------------------------------"
# echo "Installing windows compositor"
# echo "------------------------------------------"
# sudo pacman -S --noconfirm xcompmgr

echo "-------------------------------------------------------------------"
echo "Installing projecteur (pointer spotlight, for presentation)"
echo "-------------------------------------------------------------------"
yay -S --noconfirm projecteur
# Install symlink for projecteur configuration
mkdir -p $HOME/.config/Projecteur
ln -sf $pwd/HOME/.config/Projecteur/Projecteur.conf $HOME/.config/Projecteur/Projecteur.conf
# Install symlink for projecteur_action.sh (used inside i3 config)
ln -sf $pwd/HOME/.local/bin/projecteur_action.sh $HOME/.local/bin/projecteur_action.sh

echo "-------------------------------------------------------------------"
echo "Installing gromit-mpx (ZoomIt-like, for linux, for presentation)"
echo "-------------------------------------------------------------------"
# debian package is not the latest version
# check out https://github.com/bk138/gromit-mpx?tab=readme-ov-file#building-it to build from source
yay -S --noconfirm gromit-mpx
ln -sf $pwd/HOME/.local/bin/gromit-mpx $HOME/.local/bin/gromit-mpx
ln -sf $pwd/HOME/.config/gromit-mpx.cfg $HOME/.config/gromit-mpx.cfg
ln -sf $pwd/HOME/.config/gromit-mpx.ini $HOME/.config/gromit-mpx.ini
# Install symlink for gromit_mpx_action.sh (used inside i3 config)
ln -sf $pwd/HOME/.local/bin/gromit_mpx_action.sh $HOME/.local/bin/gromit_mpx_action.sh

# echo "-------------------------------------------------------------------"
# echo "Setting symlink for Boomer (zoomer for linux, for presentation)"
# echo "-------------------------------------------------------------------"
# https://github.com/tsoding/boomer
yay -S --noconfirm boomer
ln -sf $pwd/HOME/.local/bin/boomer $HOME/.local/bin/boomer

echo "-------------------------------------------------------------------"
echo "Setting symlink for date command
echo "-------------------------------------------------------------------"
ln -sf $pwd/HOME/.local/bin/date.sh $HOME/.local/bin/date.sh

# Install i3-gaps
# sudo add-apt-repository -y ppa:regolith-linux/release
# sudo pacman -Sy
# sudo pacman -S --noconfirm i3-gaps

# Install i3status config
# echo "------------------------------------------"
# echo "Installing i3status"
# echo "------------------------------------------"
# sudo pacman -S --noconfirm i3status
# Install symlink for i3status
mkdir -p $HOME/.config/i3status
ln -sf $pwd/HOME/.config/i3status/config $HOME/.config/i3status/config

# Install i3status wrapper script
echo "------------------------------------------"
echo "Installing wrapper script (for microphone)"
echo "------------------------------------------"
yay -S --noconfirm python-pulsectl
# Install symlink for the wrapper script
ln -sf $pwd/HOME/.local/bin/i3status_wrapper.py $HOME/.local/bin/i3status_wrapper.py

# Install tmux plugin manager
if [[ ! -d $HOME/.tmux/plugins/tpm ]]; then
	echo "------------------------------------------"
	echo "Installing tmux plugin manager"
	echo "------------------------------------------"
	git clone https://github.com/tmux-plugins/tpm $HOME/.tmux/plugins/tpm || true
fi

echo "------------------------------------------"
echo "tmux-resurrect folder"
echo "------------------------------------------"
mkdir -p $HOME/.tmux/resurrect/

# Setup i3
# Install symlink for i3 config
echo "------------------------------------------"
echo "Installing symlink for i3 config"
echo "------------------------------------------"
mkdir -p $HOME/.config/i3
ln -sf $pwd/HOME/.config/i3/config $HOME/.config/i3/config

# Install notify-send
# echo "------------------------------------------"
# echo "Installing notify-send"
# echo "------------------------------------------"
# sudo pacman -S --noconfirm libnotify

# Setup dunst (notification daemon)
echo "------------------------------------------"
echo "Installing symlink for dunstrc"
echo "------------------------------------------"
# sudo pacman -S --noconfirm dunst
sudo mkdir -p /etc/xdg
sudo mkdir -p /etc/xdg/dunst
sudo ln -sf $pwd/etc/xdg/dunst/dunstrc /etc/xdg/dunst/dunstrc

# Install tmux terminal multiplexer
# if ! command -v tmux &>/dev/null
# then
	echo "------------------------------------------"
	echo "Installing tmux"
	echo "------------------------------------------"
# 	sudo pacman -S --noconfirm tmux
# 	tmux_file_name=tmux_3.1c-1+deb11u1_amd64.deb
# 	rm -rf /tmp/$tmux_file_name
# 	wget http://ftp.us.debian.org/debian/pool/main/t/tmux/$tmux_file_name -O /tmp/$tmux_file_name || true
# 	sudo dpkg --install /tmp/$tmux_file_name
# 	rm -rf /tmp/$tmux_file_name
# fi
# Install symlink for tmux.conf
mkdir -p $HOME/.config/tmux
ln -sf $pwd/HOME/.config/tmux/tmux.conf $HOME/.config/tmux/tmux.conf

# Install alacritty terminal emulator
# if ! command -v alacritty &>/dev/null
# then
#   echo "------------------------------------------"
#   echo "Installing alacritty"
#   echo "------------------------------------------"
#   alacritty_file_name=alacritty_0.13.2_amd64_bullseye.deb
#   rm -rf /tmp/$alacritty_file_name
#   wget https://github.com/barnumbirr/alacritty-debian/releases/download/v0.13.2-1/$alacritty_file_name -O /tmp/$alacritty_file_name
#   sudo dpkg -i /tmp/$alacritty_file_name
#   rm -rf /tmp/$alacritty_file_name
# fi
# Install symlink for alacritty.yml
# mkdir -p $HOME/.config/alacritty
# ln -sf $pwd/HOME/.config/alacritty/alacritty.yml $HOME/.config/alacritty/alacritty.yml

# alacritty color theme
# mkdir -p ~/.config/alacritty/themes
# git clone https://github.com/alacritty/alacritty-theme ~/.config/alacritty/themes
# Install symlink for colorscheme switcher
# ln -sf $pwd/HOME/.local/bin/toggle-colorscheme.sh $HOME/.local/bin/toggle-colorscheme.sh

# Install kitty terminal emulator
# if ! command -v kitty &>/dev/null
# then
  echo "------------------------------------------"
  echo "Installing kitty"
  echo "------------------------------------------"
  # curl -L https://sw.kovidgoyal.net/kitty/installer.sh | sh

  ln -sf $pwd/HOME/.config/kitty/kitty.conf $HOME/.config/kitty/kitty.conf
  # sudo ln -sf $HOME/.local/kitty.app/bin/kitty /usr/local/bin/kitty
# fi

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

# Install symlink for init stuff
echo "------------------------------------------"
echo "Installing symlink for init stuff"
echo "------------------------------------------"
ln -sf $pwd/HOME/.local/bin/init_stuff.sh $HOME/.local/bin/init_stuff.sh

# Install symlink for detect keyboard
echo "------------------------------------------"
echo "Installing symlink for detect keyboard"
echo "------------------------------------------"
ln -sf $pwd/HOME/.local/bin/detect_keyboard.sh $HOME/.local/bin/detect_keyboard.sh

# Install vscodium
# if ! command -v codium &>/dev/null
# then
# 	echo "------------------------------------------"
# 	echo "Installing vscodium"
# 	echo "------------------------------------------"
# 	codium_file_name=codium_1.81.1.23222_amd64.deb
# 	rm -rf /tmp/$codium_file_name
# 	wget https://github.com/VSCodium/vscodium/releases/download/1.81.1.23222/$codium_file_name -O /tmp/$codium_file_name
# 	sudo dpkg --install /tmp/$codium_file_name || true
# 	rm -rf /tmp/$codium_file_name
# fi

# Install Brave browser
# sudo curl -fsSLo /usr/share/keyrings/brave-browser-archive-keyring.gpg https://brave-browser-apt-release.s3.brave.com/brave-browser-archive-keyring.gpg
# echo "deb [signed-by=/usr/share/keyrings/brave-browser-archive-keyring.gpg arch=amd64] https://brave-browser-apt-release.s3.brave.com/ stable main"|sudo tee /etc/apt/sources.list.d/brave-browser-release.list
# sudo pacman -Sy
# sudo pacman -S --noconfirm brave-browser

# Install docker
# if ! command -v docker &>/dev/null
# then
	# echo "------------------------------------------"
	# echo "Installing docker for $distro"
	# echo "------------------------------------------"
	# sudo pacman -S --noconfirm docker docker-compose
	# sudo usermod -aG docker $whoami
# fi

# Enable docker experimental mode
echo "------------------------------------------"
echo "Enable docker experimental mode, and detach keys"
echo "------------------------------------------"
mkdir -p $HOME/.docker
echo { \"experimental\" : \"enabled\", \"detachKeys\" : \"ctrl-z,z\" } > $HOME/.docker/config.json

# Install Audio controls 
# echo "------------------------------------------"
# echo "Installing audio controls"
# echo "------------------------------------------"
# sudo pacman -S --noconfirm alsa-utils pulseaudio || true

# Install brightness controls
# echo "------------------------------------------"
# echo "Installing brightness controls"
# echo "------------------------------------------"
# sudo pacman -S --noconfirm brightnessctl || true

# Install flameshot
# https://github.com/flameshot-org/flameshot
# echo "------------------------------------------"
# echo "Installing flameshot"
# echo "------------------------------------------"
# # flameshot_file_name=flameshot-12.1.0-1.$distro-$distro_version.amd64.deb
# # wget "https://github.com/flameshot-org/flameshot/releases/download/v12.1.0/$flameshot_file_name" -O /tmp/$flameshot_file_name  || true
# # sudo dpkg -i /tmp/$flameshot_file_name || true
# sudo pacman -S --noconfirm flameshot
# mkdir -p $HOME/.config/Dharkael && ln -sf $pwd/HOME/.config/flameshot/flameshot.conf $HOME/.config/Dharkael/flameshot.conf

# Install Shutter
# echo "------------------------------------------"
# echo "Installing Shutter"
# echo "------------------------------------------"
# sudo pacman -S --noconfirm shutter

# Install ksnip
# echo "------------------------------------------"
# echo "Installing ksnip"
# echo "------------------------------------------"
# sudo pacman -S --noconfirm ksnip

# Install symlink for flameshot config
mkdir -p $HOME/.config/flameshot
ln -sf $pwd/HOME/.config/flameshot/flameshot.ini $HOME/.config/flameshot/flameshot.ini

# Install barrier
# https://github.com/debauchee/barrier#distro-specific-packages
echo "------------------------------------------"
echo "Installing barrier"
echo "------------------------------------------"
yay -S --noconfirm barrier

# Install compton
# sudo pacman -S --noconfirm compton
# Install symlink for compton
# mkdir -p $HOME/.config/compton
# ln -sf $pwd/HOME/.config/compton/compton.conf $HOME/.config/compton/compton.conf

# sz (https://github.com/Zarfir/Screenz)
# chmod +x $pwd/HOME/sz
# sudo ln -sf $pwd/HOME/sz /usr/local/bin/sz

# xdotool
# echo "------------------------------------------"
# echo "Installing xdotool (moving cursor using keyboard)"
# echo "------------------------------------------"
# sudo pacman -S --noconfirm xdotool

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

echo "------------------------------------------"
echo "Installing fcitx5"
echo "Run im-config and select fcitx5"
echo "See https://fcitx-im.org/wiki/Setup_Fcitx_5"
echo "------------------------------------------"
# sudo pacman -S --noconfirm fcitx5 fcitx5-config-qt fcitx5-pinyin fcitx5-mozc
ln -sf $pwd/HOME/.config/fcitx5 $HOME/.config/fcitx5
  
echo "------------------------------------------"
echo "Installing some common tools"
echo "------------------------------------------"
# document like pdf reader
# sudo pacman -S --noconfirm okular
# inkscape
# sudo pacman -S --noconfirm inkscape
# copyq
# sudo pacman -S --noconfirm copyq
ln -sf $pwd/HOME/.config/copyq/copyq.conf $HOME/.config/copyq/copyq.conf
ln -sf $pwd/HOME/.config/copyq/copyq-commands.ini $HOME/.config/copyq/copyq-commands.ini

echo "------------------------------------------"
echo "Systemd timers"
echo "------------------------------------------"
# Check for laptop's battery level
ln -sf $pwd/HOME/.local/bin/laptop_battery_status.sh $HOME/.local/bin/laptop_battery_status.sh
sudo ln -sf $pwd/usr/lib/systemd/user/laptop_battery_status.service /usr/lib/systemd/user/laptop_battery_status.service
sudo ln -sf $pwd/usr/lib/systemd/user/laptop_battery_status.timer /usr/lib/systemd/user/laptop_battery_status.timer
systemctl --user daemon-reload
systemctl --user enable --now laptop_battery_status.timer

# shell setup
# ------------------------------ put below in the end

# bashrc
echo "------------------------------------------"
echo "Editing bashrc"
echo "------------------------------------------"
echo 'set -o vi' >> $HOME/.bashrc

# Install zsh
# echo "------------------------------------------"
# echo "Installing zsh"
# echo "------------------------------------------"
# sudo pacman -S --noconfirm zsh

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

echo "------------------------------------------"
echo "Changing shell to zsh for both root and ccw"
echo "------------------------------------------"
sudo chsh -s $(which zsh) ccw
sudo chsh -s $(which zsh)

echo "------------------------------------------"
echo "Cleaning pacman"
echo "------------------------------------------"
sudo pacman -Sc --noconfirm

# done
echo "=========================================="
echo "Setup done......"
echo "=========================================="
