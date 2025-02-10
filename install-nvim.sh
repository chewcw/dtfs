#!/bin/bash

set -e

configFileDirectory=HOME/.config/nvim
localConfigFilePath=$HOME/.config/nvim
tempFilePath=/tmp/nvim-installation-temp

mkdir -p $tempFilePath

parse_args() {
  case $1 in
    "full" )
      install_dependency
      install_nodejs
      install_nvim_v010
      configure_nvim
      clean
      ;;
    "update" )
      configure_nvim
      ;;
    "uninstall" )
      uninstall
      clean
      ;;
    * )
      install_dependency
      install_nvim_v010
      configure_nvim
      clean
      ;;
  esac
}

install_dependency() {
  echo "installing dependencies"

  sudo apt update

  # ripgrep
  [ ! $(command -v rg) ] && sudo apt install -y ripgrep || true
  # xclip and xsel
  [ ! $(command -v xclip ) ] && sudo apt install -y xclip xsel || true
  # build-essential
  sudo apt install -y build-essential || true
  # python3-venv
  sudo apt install -y python3-venv || true
  # fzf
  sudo apt install -y fzf || true
  # file
  sudo apt install -y file || true
}

install_nodejs() {
  if ! command -v node &>/dev/null; then
    echo "installing NodeJS"
    curl -sL install-node.vercel.app/lts | sudo bash -s -- --yes
  fi
  echo "NodeJS is installed"
}

install_nvim_v010() {
  echo "installing nvim v0.10.4"
  wget https://github.com/neovim/neovim/releases/download/v0.10.4/nvim-linux-x86_64.tar.gz -O /tmp/nvim-linux-x86_64.tar.gz
  tar xvzf /tmp/nvim-linux-x86_64.tar.gz -C /tmp
  sudo cp -r /tmp/nvim-linux-x86_64 /usr/local/nvim-v0-10-4
  sudo ln -sf /usr/local/nvim-v0-10-4/bin/nvim /usr/bin/nvim
  sudo ln -sf /usr/bin/nvim /usr/local/bin/v
  echo "nvim v0.10.4 is installed"
}

configure_nvim() {
  mkdir -p $localConfigFilePath
  rm -rf $localConfigFilePath/* || true
  echo "checking out the nvim config directory from github"
  cd $tempFilePath
  rm -rf dtfs/
  git clone https://github.com/chewcw/dtfs --no-checkout --depth 1 dtfs
  cd dtfs
  git sparse-checkout init --cone
  git sparse-checkout set HOME/.config/nvim
  git checkout
  cp -r $tempFilePath/dtfs/$configFileDirectory/* $localConfigFilePath
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
  # remove python3-venv
  echo "removing python3-venv"
  sudo apt remove --purge  python3-venv -y || true
}

clean() {
  sudo rm -rf $tempFilePath
}

parse_args $1
