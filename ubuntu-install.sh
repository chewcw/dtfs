#!/usr/bin/env bash

set -e -o pipefail

pwd="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
whoami="$(id -un)"

link_config_dir() {
	local source="$1" destination="$2" backup
	[[ -d "$source" ]] || { echo "Missing config directory: $source" >&2; return 1; }
	mkdir -p -- "$(dirname -- "$destination")"
	if [[ -e "$destination" && ! -L "$destination" ]]; then
		# Preserve real directories before replacing them with repository links.
		backup="$(mktemp -d "${destination}.backup.XXXXXX")"
		mv -- "$destination" "$backup/original"
		echo "Existing configuration saved to $backup/original"
	fi
	ln -sfnT -- "$source" "$destination"
}

# determining debian or ubuntu
. /etc/os-release
distro="${ID:-}"
distro_version="${VERSION_ID:-}"
case "$distro" in
	ubuntu|debian) ;;
	*) echo "Unsupported distro: $distro" >&2; exit 1 ;;
esac

echo "------------------------------------------"
echo "Distro is $distro, version is $distro_version"
echo "------------------------------------------"

sleep 3

# start
sudo apt-get update
sudo apt-get install -y apt-transport-https curl ca-certificates python3 wget unzip fontconfig xz-utils

# Create config directory
mkdir -p "$HOME/.config"

# Create local bin directory
mkdir -p "$HOME/.local/bin"

# Install git
echo "------------------------------------------"
echo "Installing git"
echo "------------------------------------------"
sudo apt install -y git

# setup global git config
echo "------------------------------------------"
echo "Setup global git config"
echo "------------------------------------------"
ln -sf "$pwd/HOME/.gitconfig" "$HOME/.gitconfig"

# Install lazygit v0.40.2
# if ! command -v lazygit &>/dev/null
# then
# 	echo "------------------------------------------"
# 	echo "Installing lazygit"
# 	echo "------------------------------------------"
# 	lazygit_tar_name=lazygit_0.40.2_Linux_x86_64.tar
# 	rm -rf /tmp/$lazygit_tar_name
# 	wget https://github.com/jesseduffield/lazygit/releases/download/v0.40.2/$lazygit_tar_name.gz -O /tmp/$lazygit_tar_name.gz
# 	gzip -d /tmp/$lazygit_tar_name.gz
# 	tar xvf /tmp/$lazygit_tar_name --directory=/tmp
# 	sudo mv /tmp/lazygit /usr/local/bin/lazygit
# fi

# Setup lazygit
# echo "------------------------------------------"
# echo "Setting up lazygit"
# echo "------------------------------------------"
# mkdir -p $HOME/.config/jesseduffield
# mkdir -p $HOME/.config/jesseduffield/lazygit
# ln -sf $pwd/HOME/.config/jesseduffield/lazygit/config.yml $HOME/.config/jesseduffield/lazygit/config.yml

# Install font
echo "------------------------------------------"
echo "Installing iosevka nerd font"
echo "------------------------------------------"
mkdir -p "$HOME/.fonts"
if ! fc-list | grep -qi iosevka; then
  wget 'https://github.com/ryanoasis/nerd-fonts/releases/download/v3.5.1/Iosevka.tar.xz' -O /tmp/Iosevka.tar.xz
  tar -xJf /tmp/Iosevka.tar.xz -C "$HOME/.fonts/"
  rm -f /tmp/Iosevka.tar.xz
  fc-cache -f
fi

# echo "------------------------------------------"
# echo "Installing InputMono font"
# echo "------------------------------------------"
# mkdir -p $HOME/.fonts
# cp $pwd/HOME/custom-fonts/InputMono/InputMonoCompressed/* $HOME/.fonts || true

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
git clone --depth 1 https://github.com/junegunn/fzf.git "$HOME/.fzf" || true
"$HOME/.fzf/install" --no-update-rc --completion --key-bindings
# sudo apt install -y fzf

# Install xsel and xclip (clipboard selection tools)
echo "------------------------------------------"
echo "Installing xsel and xclip"
echo "------------------------------------------"
sudo apt install -y xsel xclip

# Install fff
# if [[ ! -d "$HOME/.fff" ]]; then
# 	echo "------------------------------------------"
# 	echo "Installing fff"
# 	echo "------------------------------------------"
# 	git clone https://github.com/dylanaraps/fff $HOME/.fff || true
# 	sudo make -k -C $HOME/.fff install || true
# fi

# Install yazi (file manager)
if [[ ! -f "$HOME/.local/bin/yazi" ]]; then
	echo "------------------------------------------"
	echo "Installing yazi"
	echo "------------------------------------------"
  wget https://github.com/sxyazi/yazi/releases/download/v0.2.4/yazi-x86_64-unknown-linux-gnu.zip -O /tmp/yazi-x86_64-unknown-linux-gnu.zip || true;
  cd /tmp; unzip yazi-x86_64-unknown-linux-gnu.zip;
  sudo mv yazi-x86_64-unknown-linux-gnu/yazi /usr/local/bin/yazi;
  rm -rf /tmp/yazi-x86_64-unknown-linux-gnu*;
fi

# Install mapping caps to ctrl (or remapping capslock to escape AND ctrl)
# echo "------------------------------------------"
# echo "Installing interception tools and caps2esc"
# echo "------------------------------------------"
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

# sudo apt install -y interception-tools
# sudo wget https://gitlab.com/chewcw/caps2esc/-/raw/master/build/caps2esc?ref_type=heads -O /usr/bin/caps2esc
# sudo chmod +x /usr/bin/caps2esc
# sudo bash -c 'cat << EOF > /etc/interception/udevmon.yaml
# - JOB: "interception -g \$DEVNODE | caps2esc -m 3 | uinput -d \$DEVNODE"
#   DEVICE:
#       EVENTS:
#         EV_KEY: [KEY_CAPSLOCK, KEY_ESC]
# EOF'
#
# sudo systemctl restart udevmon || true

# TODO: which one is better? xcape or caps2esc?
# see: https://askubuntu.com/a/856887
# sudo apt install -y xcape
# setxkbmap -option caps:ctrl_modifier
# or just map caps to ctrl, if using above method, sometimes when press caps
# then somehow I want to cancel the action, but it turns out escape was 
# registered, so maybe it's better to separate the escape and control function.

# Install kanata binary
if [[ ! -x "$HOME/.local/bin/kanata" ]]; then
	echo "------------------------------------------"
	echo "Installing kanata from source (v1.12.0, cmd feature)"
	echo "------------------------------------------"
	sudo apt-get install -y build-essential pkg-config libudev-dev
	export PATH="$HOME/.cargo/bin:$PATH"
	if ! command -v cargo &>/dev/null; then
		curl --proto '=https' --tlsv1.2 -fsSL https://sh.rustup.rs | sh -s -- -y --profile minimal
	fi
	(
		build_dir="$(mktemp -d)"
		trap 'rm -rf -- "$build_dir"' EXIT
		git clone --depth 1 --branch v1.12.0 https://github.com/jtroo/kanata.git "$build_dir/kanata"
		cd "$build_dir/kanata"
		cargo build --release --locked --features cmd
		install -Dm755 target/release/kanata "$HOME/.local/bin/kanata"
	)
fi

# Install zhisper binary (hold-to-dictate voice input daemon)
# Built from source: https://github.com/chewcw/zhisper
# Runtime deps (libx11-6, libxext6) already come in with the X11/i3 setup below.
# Skipped with a warning if zig is not installed, since the build needs it.
if [[ ! -f "$HOME/.local/bin/zhisper" ]]; then
	if ! command -v zig &>/dev/null
	then
		echo "------------------------------------------"
		echo "WARNING: zig not found, skipping zhisper build"
		echo "         Install zig, then rerun to get ~/.local/bin/zhisper"
		echo "------------------------------------------"
	else
		echo "------------------------------------------"
		echo "Building zhisper from source"
		echo "------------------------------------------"
		cd /tmp
		rm -rf /tmp/zhisper
		git clone https://github.com/chewcw/zhisper.git /tmp/zhisper || true
		cd /tmp/zhisper
		zig build -Doptimize=ReleaseFast || true
		mkdir -p "$HOME/.local/bin"
		cp /tmp/zhisper/zig-out/bin/zhisper "$HOME/.local/bin/zhisper" || true
	fi
fi

# Setup neovim
# Install symlink for .vimrc
echo "------------------------------------------"
echo "Setting up vimrc"
echo "------------------------------------------"
ln -sf "$pwd/HOME/.vimrc" "$HOME/.vimrc"
# Install symlink for .gvimrc
echo "------------------------------------------"
echo "Setting up gvimrc"
echo "------------------------------------------"
ln -sf "$pwd/HOME/.gvimrc" "$HOME/.gvimrc"
mkdir -p "$HOME/.vim"
mkdir -p "$HOME/.vim/colors"
ln -sf "$pwd/HOME/.vim/colors/github.vim" "$HOME/.vim/colors/github.vim"

# Install Neovim (v0.11.4)
echo "------------------------------------------"
echo "Installing Neovim (v0.11.4)"
echo "------------------------------------------"
# Install the binary without letting the helper replace existing configuration.
"$pwd/install-nvim.sh" binary
link_config_dir "$pwd/HOME/.config/nvim" "$HOME/.config/nvim"

# Install i3
echo "------------------------------------------"
echo "Installing i3wm"
echo "------------------------------------------"
sudo apt install -y i3-wm i3

# ----------------------------------------------------------------------------- 
# Installing some utilities
# ----------------------------------------------------------------------------- 
echo "------------------------------------------"
echo "Installing arandr (GUI for xrandr)"
echo "------------------------------------------"
sudo apt install -y arandr

echo "-------------------------------------------------------------------"
echo "Installing pasystray (system tray for Pulse Audio - pavucontrol)"
echo "-------------------------------------------------------------------"
sudo apt install -y pasystray

echo "------------------------------------------"
echo "Installing windows compositor"
echo "------------------------------------------"
sudo apt install -y xcompmgr

echo "-------------------------------------------------------------------"
echo "Installing projecteur (pointer spotlight, for presentation)"
echo "-------------------------------------------------------------------"
sudo apt install -y projecteur
# Install symlink for projecteur configuration
mkdir -p "$HOME/.config/Projecteur"
ln -sf "$pwd/HOME/.config/Projecteur/Projecteur.conf" "$HOME/.config/Projecteur/Projecteur.conf"
# Install symlink for projecteur_action.sh (used inside i3 config)
ln -sf "$pwd/HOME/.local/bin/projecteur_action.sh" "$HOME/.local/bin/projecteur_action.sh"

echo "-------------------------------------------------------------------"
echo "Installing gromit-mpx (ZoomIt-like, for linux, for presentation)"
echo "-------------------------------------------------------------------"
# debian package is not the latest version
# check out https://github.com/bk138/gromit-mpx?tab=readme-ov-file#building-it to build from source
# sudo apt install -y gromit-mpx
ln -sf "$pwd/HOME/.local/bin/gromit-mpx" "$HOME/.local/bin/gromit-mpx"
ln -sf "$pwd/HOME/.config/gromit-mpx.cfg" "$HOME/.config/gromit-mpx.cfg"
ln -sf "$pwd/HOME/.config/gromit-mpx.ini" "$HOME/.config/gromit-mpx.ini"
# Install symlink for gromit_mpx_action.sh (used inside i3 config)
ln -sf "$pwd/HOME/.local/bin/gromit_mpx_action.sh" "$HOME/.local/bin/gromit_mpx_action.sh"

echo "-------------------------------------------------------------------"
echo "Setting symlink for Boomer (zoomer for linux, for presentation)"
echo "-------------------------------------------------------------------"
# https://github.com/tsoding/boomer
ln -sf "$pwd/HOME/.local/bin/boomer" "$HOME/.local/bin/boomer"

echo "-------------------------------------------------------------------"
echo "Setting symlink for date command"
echo "-------------------------------------------------------------------"
ln -sf "$pwd/HOME/.local/bin/date.sh" "$HOME/.local/bin/date.sh"

# Install i3-gaps
# sudo add-apt-repository -y ppa:regolith-linux/release
# sudo apt update
# sudo apt install -y i3-gaps

# Install i3blocks config
# echo "------------------------------------------"
# echo "Installing i3blocks"
# echo "------------------------------------------"
sudo apt install -y i3blocks
# Install symlink for i3blocks
mkdir -p "$HOME/.config/i3blocks"
ln -sf "$pwd/HOME/.config/i3blocks/i3blocks.conf" "$HOME/.config/i3blocks/i3blocks.conf"

# Install i3status config
# echo "------------------------------------------"
# echo "Installing i3status"
# echo "------------------------------------------"
# sudo apt install -y i3status
# Install symlink for i3status
# mkdir -p $HOME/.config/i3status
# ln -sf $pwd/HOME/.config/i3status/config $HOME/.config/i3status/config

# Install i3status wrapper script
# echo "------------------------------------------"
# echo "Installing wrapper script (for microphone)"
# echo "------------------------------------------"
# sudo apt install -y python3-pulsectl
# Install symlink for the wrapper script
# ln -sf $pwd/HOME/.local/bin/i3status_wrapper.py $HOME/.local/bin/i3status_wrapper.py

# Install tmux plugin manager
if [[ ! -d $HOME/.tmux/plugins/tpm ]]; then
	echo "------------------------------------------"
	echo "Installing tmux plugin manager"
	echo "------------------------------------------"
	git clone https://github.com/tmux-plugins/tpm "$HOME/.tmux/plugins/tpm" || true
fi

echo "------------------------------------------"
echo "tmux-resurrect folder"
echo "------------------------------------------"
mkdir -p "$HOME/.tmux/resurrect/"

# Setup i3
# Install symlink for i3 config
echo "------------------------------------------"
echo "Installing symlink for i3 config"
echo "------------------------------------------"
mkdir -p "$HOME/.config/i3"
ln -sf "$pwd/HOME/.config/i3/config" "$HOME/.config/i3/config"

# Install notify-send
echo "------------------------------------------"
echo "Installing notify-send"
echo "------------------------------------------"
sudo apt install -y libnotify-bin

# Setup dunst (notification daemon)
echo "------------------------------------------"
echo "Installing symlink for dunstrc"
echo "------------------------------------------"
sudo apt install dunst -y
sudo mkdir -p /etc/xdg
sudo mkdir -p /etc/xdg/dunst
sudo ln -sf "$pwd/etc/xdg/dunst/dunstrc" /etc/xdg/dunst/dunstrc

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
mkdir -p "$HOME/.config/tmux"
ln -sf "$pwd/HOME/.config/tmux/tmux.conf" "$HOME/.config/tmux/tmux.conf"

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
if ! command -v kitty &>/dev/null
then
#   echo "------------------------------------------"
#   echo "Installing kitty"
#   echo "------------------------------------------"
  curl -fsSL https://sw.kovidgoyal.net/kitty/installer.sh | sh
  sudo ln -sf "$HOME/.local/kitty.app/bin/kitty" /usr/local/bin/kitty
fi
mkdir -p "$HOME/.config/kitty"
ln -sf "$pwd/HOME/.config/kitty/kitty.conf" "$HOME/.config/kitty/kitty.conf"

# Install symlink for docker development script
echo "------------------------------------------"
echo "Installing symlink for docker development script"
echo "------------------------------------------"
mkdir -p "$HOME/.local"
mkdir -p "$HOME/.local/bin"
ln -sf "$pwd/HOME/.local/bin/dev.sh" "$HOME/.local/bin/dev.sh"

# Install symlink for connect monitor
echo "------------------------------------------"
echo "Installing symlink for connection_monitor"
echo "------------------------------------------"
ln -sf "$pwd/HOME/.local/bin/connect_monitor.sh" "$HOME/.local/bin/connect_monitor.sh"

# Install symlink for init stuff
echo "------------------------------------------"
echo "Installing symlink for init stuff"
echo "------------------------------------------"
ln -sf "$pwd/HOME/.local/bin/init_stuff.sh" "$HOME/.local/bin/init_stuff.sh"

echo "------------------------------------------"
echo "Installing symlink for xprofile"
echo "------------------------------------------"
ln -sf "$pwd/HOME/.xprofile" "$HOME/.xprofile"

echo "------------------------------------------"
echo "Installing symlink for autostart"
echo "------------------------------------------"
mkdir -p "$HOME/.config/autostart"
ln -sf "$pwd/HOME/.config/autostart/keyboard-rate.desktop" "$HOME/.config/autostart/keyboard-rate.desktop"

# Install symlink for detect keyboard
echo "------------------------------------------"
echo "Installing symlink for detect keyboard"
echo "------------------------------------------"
ln -sf "$pwd/HOME/.local/bin/detect_keyboard.sh" "$HOME/.local/bin/detect_keyboard.sh"

# uinput access for kanata running as a regular user
getent group input &>/dev/null || sudo groupadd --system input
getent group uinput &>/dev/null || sudo groupadd --system uinput
sudo usermod -aG input,uinput "$whoami"
sudo modprobe uinput
echo uinput | sudo tee /etc/modules-load.d/uinput.conf > /dev/null
sudo tee /etc/udev/rules.d/99-input.rules > /dev/null <<'EOF'
KERNEL=="uinput", MODE="0660", GROUP="uinput", OPTIONS+="static_node=uinput"
EOF
sudo udevadm control --reload-rules
sudo udevadm trigger
link_config_dir "$pwd/HOME/.config/kanata" "$HOME/.config/kanata"

# Copy kanata systemd service files
mkdir -p "$HOME/.config/systemd/user"
cp -f "$pwd/HOME/.config/systemd/user/kanata-65.service" "$HOME/.config/systemd/user/"
cp -f "$pwd/HOME/.config/systemd/user/kanata-75.service" "$HOME/.config/systemd/user/"
systemctl --user daemon-reload
# New group membership requires re-login. Then detect_keyboard.sh selects one layout.
systemctl --user disable --now kanata-65.service kanata-75.service

# Install zhisper: config symlink + systemd user service
mkdir -p "$HOME/.config/zhisper"
ln -sf "$pwd/HOME/.config/zhisper/config.toml" "$HOME/.config/zhisper/config.toml"
# The service reads the API key from this optional env file. Without it the
# daemon still starts, but every transcription fails until the key is set:
#   echo 'ZHISPER_API_KEY=...' > $HOME/.config/zhisper/env
if [[ -x $HOME/.local/bin/zhisper ]]; then
	cp -f "$pwd/HOME/.config/systemd/user/zhisper.service" "$HOME/.config/systemd/user/"
	systemctl --user enable --now zhisper.service || true
else
	echo "WARNING: $HOME/.local/bin/zhisper not found, skipping zhisper service."
fi

# Install symlink for ptrkeys binary
# ln -sf $pwd/HOME/.local/bin/ptrkeys $HOME/.local/bin/ptrkeys
# systemctl --user enable --now ptrkeys.service || true

# Copy ptrkeys systemd user service file
# mkdir -p $HOME/.config/systemd/user
# cp -f $pwd/HOME/.config/systemd/user/ptrkeys.service $HOME/.config/systemd/user/

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
	sudo usermod -aG docker "$whoami"
fi

# Enable docker experimental mode
echo "------------------------------------------"
echo "Enable docker experimental mode, and detach keys"
echo "------------------------------------------"
mkdir -p "$HOME/.docker"
python3 - "$HOME/.docker/config.json" <<'PY'
import json
import os
from pathlib import Path
import sys
import tempfile

path = Path(sys.argv[1]).resolve()
config = json.loads(path.read_text()) if path.exists() else {}
config.update(experimental="enabled", detachKeys="ctrl-z,z")
# Replace atomically so a failed write cannot truncate registry credentials.
fd, temporary = tempfile.mkstemp(dir=path.parent)
try:
    with os.fdopen(fd, "w") as output:
        json.dump(config, output, indent=2)
        output.write("\n")
    os.replace(temporary, path)
finally:
    if os.path.exists(temporary):
        os.unlink(temporary)
PY

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
echo "------------------------------------------"
echo "Installing flameshot"
echo "------------------------------------------"
# flameshot_file_name=flameshot-12.1.0-1.$distro-$distro_version.amd64.deb
# wget "https://github.com/flameshot-org/flameshot/releases/download/v12.1.0/$flameshot_file_name" -O /tmp/$flameshot_file_name  || true
# sudo dpkg -i /tmp/$flameshot_file_name || true
sudo apt install flameshot -y

# Install Shutter
# echo "------------------------------------------"
# echo "Installing Shutter"
# echo "------------------------------------------"
# sudo apt install shutter -y

# Install ksnip
echo "------------------------------------------"
echo "Installing ksnip"
echo "------------------------------------------"
sudo apt install -y ksnip

# Install symlink for flameshot config
mkdir -p "$HOME/.config/flameshot"
ln -sf "$pwd/HOME/.config/flameshot/flameshot.ini" "$HOME/.config/flameshot/flameshot.ini"

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

# xdotool
echo "------------------------------------------"
echo "Installing xdotool (moving cursor using keyboard)"
echo "------------------------------------------"
sudo apt install -y xdotool

# X11 configuration using libinput as input driver
echo "------------------------------------------"
echo "X11 configuration using libinput"
echo "------------------------------------------"
# from https://cravencode.com/post/essentials/enable-tap-to-click-in-i3wm/
# from https://unix.stackexchange.com/questions/567974/how-to-make-3-finger-tap-on-touchpad-act-as-middle-mouse-button-for-debian-10-c
# how do I configure my device on X: https://wayland.freedesktop.org/libinput/doc/latest/faqs.html#how-do-i-configure-my-device-on-x
# see libinput configuration option: https://www.mankier.com/4/libinput
sudo mkdir -p /etc/X11/xorg.conf.d
sudo ln -sf "$pwd/etc/X11/xorg.conf.d/30-touchpad.conf" /etc/X11/xorg.conf.d/30-touchpad.conf
sudo tee <<'EOF' /etc/X11/xorg.conf.d/90-touchpad.conf 1> /dev/null
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
sudo apt install -y fcitx5 fcitx5-config-qt fcitx5-pinyin fcitx5-mozc
link_config_dir "$pwd/HOME/.config/fcitx5" "$HOME/.config/fcitx5"
 
echo "------------------------------------------"
echo "Installing some common tools"
echo "------------------------------------------"
# document like pdf reader
sudo apt install -y okular
# inkscape
sudo apt install -y inkscape
# copyq
sudo apt install -y copyq
mkdir -p "$HOME/.config/copyq"
ln -sf "$pwd/HOME/.config/copyq/copyq.conf" "$HOME/.config/copyq/copyq.conf"
ln -sf "$pwd/HOME/.config/copyq/copyq-commands.ini" "$HOME/.config/copyq/copyq-commands.ini"

echo "------------------------------------------"
echo "Systemd timers"
echo "------------------------------------------"
# Check for laptop's battery level
ln -sf "$pwd/HOME/.local/bin/laptop_battery_status.sh" "$HOME/.local/bin/laptop_battery_status.sh"
sudo ln -sf "$pwd/usr/lib/systemd/user/laptop_battery_status.service" /usr/lib/systemd/user/laptop_battery_status.service
sudo ln -sf "$pwd/usr/lib/systemd/user/laptop_battery_status.timer" /usr/lib/systemd/user/laptop_battery_status.timer
systemctl --user daemon-reload
systemctl --user enable --now laptop_battery_status.timer

# shell setup
# ------------------------------ put below in the end

# bashrc
echo "------------------------------------------"
echo "Editing bashrc"
echo "------------------------------------------"
echo 'set -o vi' >> "$HOME/.bashrc"

# Install zsh
echo "------------------------------------------"
echo "Installing zsh"
echo "------------------------------------------"
sudo apt install -y zsh

# Setup oh-my-zsh and Powerlevel10k
if [[ ! -d "$HOME/.oh-my-zsh" ]]; then
	echo "------------------------------------------"
	echo "Installing oh-my-zsh"
	echo "------------------------------------------"
	curl -fsSL https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh | \
		RUNZSH=no CHSH=no KEEP_ZSHRC=yes bash
fi

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
	git clone https://github.com/zsh-users/zsh-autosuggestions "${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins/zsh-autosuggestions" || true
fi

# install zsh-vi-mode
# git clone https://github.com/jeffreytse/zsh-vi-mode ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins/zsh-vi-mode || true

# Install symlink for .zshrc
echo "------------------------------------------"
echo "Installing symlink for .zshrc"
echo "------------------------------------------"
ln -sf "$pwd/HOME/.zshrc" "$HOME/.zshrc"

# zsh plugin
# bd (jump to parent directory easily)
# mkdir -p $HOME/zsh/plugins || true
# ln -sf $pwd/HOME/zsh/plugins/bd.zsh $HOME/zsh/plugins/bd.zsh

echo "------------------------------------------"
# Change the current user's shell, but leave root unchanged.
if [[ "$whoami" != root ]]; then
	echo "Changing shell to zsh for $whoami"
	echo "------------------------------------------"
	sudo chsh -s "$(command -v zsh)" "$whoami"
fi

echo "------------------------------------------"
echo "Cleaning apt"
echo "------------------------------------------"
sudo apt clean

# done
echo "=========================================="
echo "Setup done......"
echo "=========================================="
