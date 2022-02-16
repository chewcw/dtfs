#!/usr/bin/env bash

set -e

pwd=`pwd` whoami=`whoami`
sudo apt-get update
sudo apt-get install -y apt-transport-https curl

# Create config directory
mkdir -p $HOME/.config

# Install git
sudo apt install -y git

# Install lazygit
sudo add-apt-repository -y ppa:lazygit-team/release
sudo apt update
sudo apt install -y lazygit
# Setup lazygit
mkdir -p $HOME/.config/jesseduffield
mkdir -p $HOME/.config/jesseduffield/lazygit
ln -sf $pwd/HOME/.config/jesseduffield/lazygit/config.yml $HOME/.config/jesseduffield/lazygit/config.yml
sudo rm /etc/apt/sources.list.d/lazygit-team-ubuntu-release-focal.list

# Install font (Iosevka-SS03)
wget https://github.com/be5invis/Iosevka/releases/download/v10.1.1/ttc-sgr-iosevka-fixed-ss03-10.1.1.zip -O /tmp/ttc-sgr-iosevka-fixed-ss03-10.1.1.zip
mkdir -p $HOME/.fonts
unzip -o /tmp/ttc-sgr-iosevka-fixed-ss03-10.1.1.zip -d $HOME/.fonts

# Install gnome-vim
# Use vim-gtk3 so that I have +xterm_clipboard support
sudo apt install -y vim-gtk3

# Install fzf
git clone --depth 1 https://github.com/junegunn/fzf.git $HOME/.fzf || true
$HOME/.fzf/install --no-update-rc --completion --key-bindings

# Install fff
git clone https://github.com/dylanaraps/fff $HOME/.fff || true
sudo make -C $HOME/.fff install

# Setup vim
# Install symlink for .vimrc
ln -sf $pwd/HOME/.vimrc $HOME/.vimrc

# Install Neovim (nightly)
./install-nvim.sh
ln -sf $pwd/HOME/.config/nvim/init.vim $HOME/.config/nvim/init.vim

# Install i3
sudo apt install -y i3-wm i3

# Install i3-gaps
sudo add-apt-repository -y ppa:regolith-linux/release
sudo apt update
sudo apt install -y i3-gaps

# Install i3status config
sudo apt install -y i3status
# Install symlink for i3status
mkdir -p $HOME/.config/i3status
ln -sf $pwd/HOME/.config/i3status/config $HOME/.config/i3status/config

# Setup i3
# Install tmux plugin manager
git clone https://github.com/tmux-plugins/tpm $HOME/.tmux/plugins/tpm || true

# Install symlink for i3 config
mkdir -p $HOME/.config/i3
ln -sf $pwd/HOME/.config/i3/config $HOME/.config/i3/config

# Install tmux terminal multiplexer
sudo apt install -y tmux
# Install symlink for .tmux.conf
ln -sf $pwd/HOME/.tmux.conf $HOME/.tmux.conf

# Install alacritty terminal emulator
sudo add-apt-repository -y ppa:mmstick76/alacritty
sudo apt update
sudo apt install -y alacritty
# Install symlink for alacritty.yml
mkdir -p $HOME/.config/alacritty
ln -sf $pwd/HOME/.config/alacritty/alacritty.yml $HOME/.config/alacritty/alacritty.yml

# Install vscode
sudo apt install -y software-properties-common apt-transport-https curl
curl -sSL https://packages.microsoft.com/keys/microsoft.asc | sudo apt-key add -
sudo add-apt-repository -y "deb [arch=amd64] https://packages.microsoft.com/repos/vscode stable main"
sudo apt update
sudo apt install -y code

# Install Brave browser
sudo curl -fsSLo /usr/share/keyrings/brave-browser-archive-keyring.gpg https://brave-browser-apt-release.s3.brave.com/brave-browser-archive-keyring.gpg
echo "deb [signed-by=/usr/share/keyrings/brave-browser-archive-keyring.gpg arch=amd64] https://brave-browser-apt-release.s3.brave.com/ stable main"|sudo tee /etc/apt/sources.list.d/brave-browser-release.list
sudo apt update
sudo apt install -y brave-browser

# Install docker
sudo apt update
sudo apt install -y \
	ca-certificates \
	gnupg-agent \
	software-properties-common
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
sudo add-apt-repository \
	"deb [arch=amd64] https://download.docker.com/linux/ubuntu \
	$(lsb_release -cs) \
	stable"
sudo apt update
sudo apt install -y docker-ce
sudo usermod -aG docker $whoami

# Enable docker experimental mode
mkdir -p $HOME/.docker
echo { \"experimental\" : \"enabled\" } > $HOME/.docker/config.json

# Install vlc
sudo apt install -y vlc

# Install Audio controls 
sudo apt install -y alsa-utils pulseaudio

# Install brightness controls
sudo apt install -y brightnessctl

# Install flameshot
# https://github.com/flameshot-org/flameshot
wget "https://github.com/flameshot-org/flameshot/releases/download/v0.10.1/flameshot-0.10.1-1.ubuntu-20.04.amd64.deb" -O /tmp/flameshot.deb  || true
sudo dpkg -i /tmp/flameshot.deb || true
ln -sf $pwd/HOME/.config/flameshot/flameshot.conf $HOME/.config/Dharkael/flameshot.conf

# Install feh for desktop background
sudo apt install -y feh

# Install barrier
# https://github.com/debauchee/barrier#distro-specific-packages
sudo apt install -y barrier

# Install compton
sudo apt install -y compton
# Install symlink for compton
mkdir -p $HOME/.config/compton
ln -sf $pwd/HOME/.config/compton/compton.conf $HOME/.config/compton/compton.conf

# sz (https://github.com/Zarfir/Screenz)
chmod +x $pwd/HOME/sz
sudo ln -sf $pwd/HOME/sz /usr/local/bin/sz

# ------------------------------ put below in the end
# Setup oh-my-zsh -> Powerlevel10k
sh -c "$(curl -fsSL https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" || true
git clone --depth=1 https://github.com/romkatv/powerlevel10k.git ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/powerlevel10k || true
# install zsh-autosuggestion
git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins/zsh-autosuggestions || true
# install zsh-vi-mode
git clone https://github.com/jeffreytse/zsh-vi-mode ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins/zsh-vi-mode || true

# Install symlink for .zshrc
ln -sf $pwd/HOME/.zshrc $HOME/.zshrc

# Install zsh
sudo apt install -y zsh

# set zsh as default shell
sudo chsh -s $(which zsh)

# done
echo "Setup done.."

