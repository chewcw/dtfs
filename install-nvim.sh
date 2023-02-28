#!/bin/bash

set -e

configFileDirectory=https://github.com/chewcw/dtfs/trunk/HOME/.config/nvim
localConfigFilePath=$HOME/.config/nvim
localConfigFile=init.vim
localNvimPath=$HOME/.local/nvim

parse_args() {
	case $1 in
		"full" )
			install_dependency
			install_nodejs
			install_nvim_nightly
			configure_nvim
			install_and_configure_plug
			install_common_coc
			;;
		"update" )
			configure_nvim
			;;
		"uninstall" )
			uninstall
			;;
		* )
			install_dependency
			install_nvim_nightly
			configure_nvim
			install_and_configure_plug
			;;
	esac
}

install_dependency() {
	echo "installing dependencies"

	# Ag
	sudo apt update
	[ ! $(command -v ag) ] && sudo apt install -y silversearcher-ag || true
	# svn
	[ ! $(command -v svn) ] && sudo apt install -y subversion || true
	# ripgrep
	[ ! $(command -v rg) ] && sudo apt install -y ripgrep || true

	# Install fff
	if [ ! -d "$HOME/.fff" ]; then
		echo "cloning fff"
		git clone https://github.com/dylanaraps/fff $HOME/.fff || true
		sudo make -k -C $HOME/.fff install || true
	fi

}

install_nodejs() {
	if ! command -v node &>/dev/null; then
		echo "installing NodeJS"
		curl -sL install-node.vercel.app/lts | bash -s -- --yes
	fi
	echo "NodeJS is installed"
}

install_nvim_nightly() {
	if ! command -v nvim &>/dev/null; then
		echo "installing nvim nightly"
		mkdir -p $localNvimPath
		curl -Lo /tmp/nvim-linux64.tar.gz https://github.com/neovim/neovim/releases/download/nightly/nvim-linux64.tar.gz
		tar -xf /tmp/nvim-linux64.tar.gz -C /tmp/ || true
		mv /tmp/nvim-linux64/* $localNvimPath || true
		sudo ln -sf $localNvimPath/bin/nvim /usr/local/bin/nvim
		rm -rf /tmp/nvim-linux64 || true
	fi
	echo "nvim nightly is installed"
}

install_and_configure_plug() {
	echo "installing and configuring plug"
	sh -c 'curl -fLo "${XDG_DATA_HOME:-$HOME/.local/share}"/nvim/site/autoload/plug.vim --create-dirs https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim' || true
	$localNvimPath/bin/nvim -u $localConfigFilePath/$localConfigFile +PlugInstall +qa
}

install_common_coc() {
	echo "installing common coc"
	$localNvimPath/bin/nvim +'CocInstall -sync coc-go coc-pyright coc-tsserver' +qa
}

configure_nvim() {
	mkdir -p $localConfigFilePath
	rm -rf $localConfigFilePath/$localConfigFile || true
	echo "svn checking out the nvim config directory from github"
	cd $localConfigFilePath && svn checkout $configFileDirectory
}

uninstall() {
	# remove neovim
	echo "removing nvim"
	rm -rf $localNvimPath || true
	rm -rf /usr/local/bin/nvim || true
	# remove neovim related files
	echo "removing nvim related files"
	rm -rf $localConfigFilePath || true
	rm -rf $HOME/AppData/Local/nvim || true
	# remove nodejs
	echo "removing NodeJS"
	rm -rf /usr/local/bin/node /usr/local/bin/npm /usr/local/bin/npx || true
	rm -rf /usr/local/lib/node_modules || true
	# remove svn
	echo "removing svn"
	sudo apt remove --purge subversion -y || true
	# remove ag
	echo "removing ag"
	sudo apt remove --purge silversearcher-ag -y || true
}

parse_args $1

