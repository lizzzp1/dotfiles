#!/bin/bash

echo "Beginning setting up Dotfiles..."
CODESPACES_DOTFILES="/workspaces/.codespaces/.persistedshare/dotfiles"
DOTFILES=$(pwd)

function create_symlinks() {
  ln -sf $1/.zshrc $HOME/.zshrc
  ln -sf $1/.config/nvim/* $HOME/.config/nvim/.
  ln -sf $1/.aliases $HOME/.aliases
  ln -sf $1/.zsh_profile $HOME/.zsh_profile
  ln -sf $1/.config/nvim/init.vim $HOME/.config/nvim/init.vim
  ln -sf $1/.vimrc $HOME/.vimrc
  ln -sf $1/.tmux.conf $HOME/.tmux.conf
  ln -sf $1/.psqlrc $HOME/.psqlrc
  ln -sf $1/.gitconfig $HOME/.gitconfig
}

function install_packages() {
  sudo apt-get update
  sudo apt install -y python3 python3-pip ripgrep
  sudo apt install -y zsh nodejs npm fzf tmux
}

function lsp_setup() {
  gem install ruby-lsp
}

function tmux_setup() {
  mkdir -p $HOME/.tmux/plugins
  git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm
  if [ -d ~/.tmux/plugins/tpm ]; then
    chmod +x ~/.tmux/plugins/tpm/scripts/install_plugins.sh
  fi
}

create_symlinks $CODESPACES_DOTFILES
install_packages
lsp_setup
tmux_setup
