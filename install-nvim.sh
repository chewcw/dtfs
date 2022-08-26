#!/bin/bash

set -e

configFilePath=https://raw.githubusercontent.com/chewcw/dtfs/main/HOME/.config/nvim/init.vim
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
	# Ag
	sudo apt update
	sudo apt install -y silversearcher-ag || true

	# Install fff
	if [ ! -d "$HOME/.fff" ]; then
		git clone https://github.com/dylanaraps/fff $HOME/.fff || true
		sudo make -k -C $HOME/.fff install || true
	fi

}

install_nodejs() {
	curl -sL install-node.vercel.app/lts | bash -s -- --yes
}

install_nvim_nightly() {
	mkdir -p $localNvimPath
	curl -Lo /tmp/nvim-linux64.tar.gz https://github.com/neovim/neovim/releases/download/nightly/nvim-linux64.tar.gz
	tar -xf /tmp/nvim-linux64.tar.gz -C /tmp/ || true
	mv /tmp/nvim-linux64/* $localNvimPath || true
	sudo ln -sf $localNvimPath/bin/nvim /usr/local/bin/nvim
	rm -rf /tmp/nvim-linux64 || true
}

install_and_configure_plug() {
	sh -c 'curl -fLo "${XDG_DATA_HOME:-$HOME/.local/share}"/nvim/site/autoload/plug.vim --create-dirs https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim' || true
	$localNvimPath/bin/nvim -u $localConfigFilePath/$localConfigFile +PlugInstall +qa
}

install_common_coc() {
	$localNvimPath/bin/nvim +'CocInstall -sync coc-go coc-pyright coc-tsserver' +qa
}

configure_nvim() {
	mkdir -p $localConfigFilePath
	rm -rf $localConfigFilePath/$localConfigFile || true
	curl -o $localConfigFilePath/$localConfigFile $configFilePath
}

uninstall() {
	# remove neovim
	rm -rf $localNvimPath || true
	rm -rf /usr/local/bin/nvim || true
	# remove neovim related files
	rm -rf $localConfigFilePath || true
	rm -rf $HOME/AppData/Local/nvim || true
	# remove nodejs
	rm -rf /usr/local/bin/node /usr/local/bin/npm /usr/local/bin/npx || true
	rm -rf /usr/local/lib/node_modules || true
}

parse_args $1

