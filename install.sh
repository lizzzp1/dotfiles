#!/bin/bash

echo "Beginning setting up Dotfiles..."
CODESPACES_DOTFILES="/workspaces/.codespaces/.persistedshare/dotfiles"
DOTFILES=$(pwd)

function create_symlinks() {
  ln -sf $1/.zshrc $HOME/.zshrc
  ln -sf $1/.zsh_profile $HOME/.zsh_profile
  ln -sf $1/.config/nvim/init.vim
  ln -sf $1/.vimrc $HOME/.vimrc
  ln -sf $1/.tmux.conf $HOME/.tmux.conf
  ln -sf $1/.psqlrc $HOME/.psqlrc
  ln -sf $1/.gitconfig $HOME/.gitconfig
}

function install_packages() {
  sudo apt-get update
  sudo apt install -y python3 python3-pip ripgrep
  sudo apt install -y zsh nodejs npm fzf tmux
  sudo apt-get install -y neovim
  which nvim || echo "Neovim did not installed correctly."
  # Install vim-plug if it's not installed
  curl -fLo ~/.local/share/nvim/site/autoload/plug.vim --create-dirs \
    https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
}

function lsp_setup() {
  gem install solargraph
}

function tmux_setup() {
  mkdir -p $HOME/.tmux/plugins
  git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm
  chomod +x ~/.tmux/plugins/tpm/scripts/install_plugins.sh
}

function nvim_setup() {
  ### neovim configuration setup
  mkdir -p $HOME/.config/nvim
  ## Set zsh as the default shell
  sudo chsh "$(id -un)" --shell "/usr/bin/zsh"

  ## Install plugins automatically
  nvim --headless +PluginInstall +qall
}


if [ -e "$CODESPACES_DOTFILES" ]; then
  create_symlinks $CODESPACES_DOTFILES
  install_packages
  nvim_setup
  ## Copilot setup
  git clone https://github.com/github/copilot.vim ~/.config/nvim/pack/github/start/copilot.vim
  git clone -b canary https://github.com/CopilotC-Nvim/CopilotChat.nvim ~/.config/nvim/pack/github/start/CopilotChat.nvim

  tmux_setup
else
  create_symlinks $DOTFILES
fi

if [ -d "$HOME/nvim/usr/share/nvim/runtime" ]; then
  echo "export VIMRUNTIME=$HOME/nvim/usr/share/nvim/runtime" >> ~/.zshrc
fi

echo "Dotfile setup complete."
