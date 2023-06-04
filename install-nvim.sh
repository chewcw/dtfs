#!/bin/bash

set -e

configFileDirectory=https://github.com/chewcw/dtfs/trunk/HOME/.config/nvim
localConfigFilePath=$HOME/.config/nvim

parse_args() {
	case $1 in
		"full" )
			install_dependency
			install_nodejs
			install_nvim_v091
			configure_nvim
			;;
		"update" )
			configure_nvim
			;;
		"uninstall" )
			uninstall
			;;
		* )
			install_dependency
			install_nvim_v091
			configure_nvim
			;;
	esac
}

install_dependency() {
	echo "installing dependencies"

	# svn
	[ ! $(command -v svn) ] && sudo apt install -y subversion || true
	# ripgrep
	[ ! $(command -v rg) ] && sudo apt install -y ripgrep || true
  # xclip and xsel
  [ ! $(command -v xclip ) ] && sudo apt install -y xclip xsel || true
  # build-essential
  sudo apt install -y build-essential || true
  # python3-venv
  sudo apt install -y python3-venv || true
}

install_nodejs() {
	if ! command -v node &>/dev/null; then
		echo "installing NodeJS"
		curl -sL install-node.vercel.app/lts | sudo bash -s -- --yes
	fi
	echo "NodeJS is installed"
}

install_nvim_v091() {
  if ! command -v nvim &>/dev/null; then
    echo "installing nvim v0.9.1"
    wget https://github.com/neovim/neovim/releases/download/v0.9.1/nvim-linux64.tar.gz -O /tmp/nvim-linux64.tar.gz
    tar xvzf /tmp/nvim-linux64.tar.gz -C /tmp
    sudo cp -r /tmp/nvim-linux64 /usr/local/nvim
    sudo ln -sf /usr/local/nvim/bin/nvim /usr/bin/nvim
    rm -rf /tmp/nvim-linux64.tar.gz
  fi
  echo "nvim v0.9.1 is installed"
}

configure_nvim() {
	mkdir -p $localConfigFilePath
	rm -rf $localConfigFilePath/* || true
	echo "svn checking out the nvim config directory from github"
	cd $localConfigFilePath && svn checkout $configFileDirectory .
}

uninstall() {
	# remove neovim
	echo "removing nvim"
  sudo apt remove --purge nvim
	# remove neovim related files
	echo "removing nvim related files"
	rm -rf $localConfigFilePath || true
	rm -rf $HOME/AppData/Local/nvim || true
	# remove nodejs
	echo "removing NodeJS"
	sudo rm -rf /usr/local/bin/node /usr/local/bin/npm /usr/local/bin/npx || true
	sudo rm -rf /usr/local/lib/node_modules || true
	# remove svn
	echo "removing svn"
	sudo apt remove --purge subversion  -y || true
	# remove python3-venv
  echo "removing python3-venv"
  sudo apt remove --purge  python3-venv -y || true
}

parse_args $1

