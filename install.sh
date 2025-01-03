#!/bin/bash

echo "Beginning setting up Dotfiles..."
CODESPACES_DOTFILES="/workspaces/.codespaces/.persistedshare/dotfiles"
DOTFILES=$(pwd)

function create_symlinks() {
  cp $1/.zshrc $HOME/.zshrc
  cp -r $1/.config/nvim/* $HOME/.config/nvim/.
  cp $1/.aliases $HOME/.aliases
  cp $1/.zsh_profile $HOME/.zsh_profile
  cp $1/.config/nvim/init.vim
  cp $1/.vimrc $HOME/.vimrc
  cp $1/.tmux.conf $HOME/.tmux.conf
  cp $1/.psqlrc $HOME/.psqlrc
  cp $1/.gitconfig $HOME/.gitconfig
}

function install_packages() {
  sudo apt-get update
  sudo apt install -y python3 python3-pip ripgrep
  sudo apt install -y zsh nodejs npm fzf tmux
}

function lsp_setup() {
  gem install solargraph
}

function tmux_setup() {
  mkdir -p $HOME/.tmux/plugins
  git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm
  if [ -d ~/.tmux/plugins/tpm ]; then
    chmod +x ~/.tmux/plugins/tpm/scripts/install_plugins.sh
  fi
}

function nvim_setup() {
  sudo mkdir -p ~/.config/nvim
  sudo apt-get install -y neovim
  which nvim || echo "Neovim did not install correctly."
  # Install vim-plug if it's not installed
  sudo curl -fLo ~/.local/share/nvim/site/autoload/plug.vim --create-dirs \
    https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
}


if [ -e "$CODESPACES_DOTFILES" ]; then
  nvim_setup
  install_packages
  create_symlinks $CODESPACES_DOTFILES
  tmux_setup
else
  create_symlinks $DOTFILES
fi

if [ -d "$HOME/nvim/usr/share/nvim/runtime" ]; then
  echo "export VIMRUNTIME=$HOME/nvim/usr/share/nvim/runtime" >> ~/.zshrc
fi

echo "Dotfile setup complete."
