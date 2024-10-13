#!/bin/bash

echo "Beginning setting up Dotfiles..."

make all

sudo apt update && sudo apt install -y zsh nodejs npm fzf tmux
## Install specific version of neovim
wget -O $HOME/nvim.appimage https://github.com/neovim/neovim/releases/download/v0.9.5/nvim.appimage
chmod 755 $HOME/nvim.appimage
sudo $HOME/nvim.appimage --appimage-extract
sudo mv ./squashfs-root $HOME/nvim
sudo ln $HOME/nvim/usr/bin/nvim /usr/bin/nvim

### Neovim configuration setup
mkdir -p $HOME/.config/nvim
#
## Set zsh as the default shell
sudo chsh "$(id -un)" --shell "/usr/bin/zsh"
#
## Install plugins automatically
nvim --headless +PluginInstall +qall
#
## LSP setup
gem install solargraph
sudo npm install -g typescript typescript-language-server

## Copilot setup
git clone https://github.com/github/copilot.vim ~/.config/nvim/pack/github/start/copilot.vim
git clone -b canary https://github.com/CopilotC-Nvim/CopilotChat.nvim ~/.config/nvim/pack/github/start/CopilotChat.nvim
#
## Tmux plugin setup
mkdir -p $HOME/.tmux/plugins
git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm

~/.tmux/plugins/tpm/scripts/install_plugins.sh

echo "export VIMRUNTIME=$HOME/nvim/usr/share/nvim/runtime" >> ~/.zshrc
echo "Dotfile setup complete."
