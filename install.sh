#!/usr/bin/env bash
set -euo pipefail
echo "Setting up NeoVim, tmux, asdf, LSPs, and dotfiles for macOS or Linux..."

DOTFILES="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
OS="$(uname -s)"

if [ "$OS" == "Darwin" ]; then
  PACKAGE_MANAGER="brew"
  INSTALL_CMD="brew install"
elif [ "$OS" == "Linux" ]; then
  PACKAGE_MANAGER="apt"
  INSTALL_CMD="sudo apt-get install -y"
else
  echo "Unsupported OS"
  exit 1
fi

if [[ "$PACKAGE_MANAGER" == "brew" ]]; then
  if ! command -v brew >/dev/null 2>&1; then
    echo "Homebrew is not installed. Installing Homebrew..."
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    if [ -d "/opt/homebrew/bin" ]; then
      eval "$(/opt/homebrew/bin/brew shellenv)"
    elif [ -d "/usr/local/bin" ]; then
      eval "$(/usr/local/bin/brew shellenv)"
    fi
  fi
else
  echo "Updating apt..."
  sudo apt-get update -y
fi

for pkg in git tmux neovim; do
  if ! command -v "$pkg" >/dev/null 2>&1; then
    echo "Installing $pkg..."
    $INSTALL_CMD "$pkg"
  fi
done

if ! command -v asdf >/dev/null 2>&1; then
  echo "Installing asdf version manager..."
  if [[ "$PACKAGE_MANAGER" == "brew" ]]; then
    brew install asdf
    . "$(brew --prefix asdf)/libexec/asdf.sh"
  else
    git clone https://github.com/asdf-vm/asdf.git ~/.asdf --branch v0.14.0
    echo '. "$HOME/.asdf/asdf.sh"' >> ~/.bashrc
    echo '. "$HOME/.asdf/completions/asdf.bash"' >> ~/.bashrc
  fi
fi

for plugin in nodejs python ruby golang; do
  if ! asdf plugin list | grep -q "$plugin"; then
    echo "Adding asdf plugin: $plugin"
    asdf plugin add "$plugin"
  fi
done

if ! command -v pipx >/dev/null 2>&1; then
  echo "Installing pipx..."
  $INSTALL_CMD pipx || $INSTALL_CMD python3-pip
  python3 -m pip install --user pipx
  python3 -m pipx ensurepath
fi

echo "Symlinking dotfiles..."
mkdir -p "$HOME/.config/nvim"
mkdir -p "$HOME/.config/ghostty"
ln -sf "$DOTFILES/.zshrc" "$HOME/.zshrc"
ln -sf "$DOTFILES/.aliases" "$HOME/.aliases"
ln -sf "$DOTFILES/.vimrc" "$HOME/.vimrc"
ln -sf "$DOTFILES/.tmux.conf" "$HOME/.tmux.conf"
ln -sf "$DOTFILES/.psqlrc" "$HOME/.psqlrc"
ln -sf "$DOTFILES/.gitconfig" "$HOME/.gitconfig"
ln -sf "$DOTFILES/.config/ghostty" "$HOME/.config/ghostty"
if [ -f "$DOTFILES/.bashrc" ]; then
  ln -sf "$DOTFILES/.bashrc" "$HOME/.bashrc"
fi

echo "Symlinking nvim config recursively..."
if [ -d "$DOTFILES/.config/nvim" ]; then
  cd "$DOTFILES/.config/nvim"
  for item in *; do
    ln -sfn "$DOTFILES/.config/nvim/$item" "$HOME/.config/nvim/$item"
  done
fi

echo "Installing Python LSP (pyright) with pipx..."
pipx install --force pyright

echo "Installing Ruby LSP (ruby-lsp)..."
if command -v rbenv >/dev/null 2>&1; then
  eval "$(rbenv init -)"
  gem install ruby-lsp
else
  gem install ruby-lsp --user-install
fi

echo "Installing Node.js and LSPs (typescript, bash)..."
if ! command -v npm >/dev/null 2>&1; then
  if command -v asdf >/dev/null 2>&1; then
    if ! asdf plugin-list | grep -q nodejs; then
      asdf plugin-add nodejs
    fi
    asdf install nodejs latest
    asdf global nodejs latest
  elif [ "$PACKAGE_MANAGER" == "brew" ]; then
    brew install node
  elif [ "$PACKAGE_MANAGER" == "apt" ]; then
    curl -fsSL https://deb.nodesource.com/setup_20.x | sudo -E bash -
    sudo apt-get install -y nodejs
  else
    echo "Unsupported system for Node installation."
    exit 1
  fi
else
  echo "Node.js already installed."
fi

npm install -g typescript typescript-language-server bash-language-server

echo "Installing Go LSP (gopls)..."
if asdf where golang >/dev/null 2>&1; then
  go install golang.org/x/tools/gopls@latest
else
  brew install gopls
fi

if [ ! -d "$HOME/.tmux/plugins/tpm" ]; then
  echo "Installing tmux plugin manager..."
  git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm
else
  echo "tmux plugin manager already installed."
fi

if [ ! -d "$HOME/.tmux/plugins/tmux-resurrect" ]; then
  echo "Installing tmux resurrect plugin..."
  git clone https://github.com/tmux-plugins/tmux-resurrect ~/.tmux/plugins/tmux-resurrect
  tmux source-file ~/.tmux.conf
else
  echo "tmux resurrect is already installed."
fi

if [ ! -f "$HOME/.vim/autoload/plug.vim" ]; then
  echo "Installing vim-plug for Vim..."
  curl -fLo "$HOME/.vim/autoload/plug.vim" --create-dirs \
    https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
else
  echo "vim-plug already installed."
fi

echo "✅ All done!"
