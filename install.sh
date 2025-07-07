#!/bin/bash
set -e

echo "Setting up NeoVim, tmux, asdf, LSPs, and dotfiles for macOS..."

DOTFILES="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

# --- Homebrew install/check ---
if ! command -v brew >/dev/null 2>&1; then
    echo "Homebrew is not installed. Installing Homebrew..."
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    # Add Homebrew to PATH for current script execution
    if [ -d "/opt/homebrew/bin" ]; then
        eval "$(/opt/homebrew/bin/brew shellenv)"
    elif [ -d "/usr/local/bin" ]; then
        eval "$(/usr/local/bin/brew shellenv)"
    fi
fi

# --- asdf install & setup ---
if ! command -v asdf >/dev/null 2>&1; then
    echo "Installing asdf version manager..."
    brew install asdf
fi

if ! grep -q 'asdf.sh' "$HOME/.zshrc"; then
    echo "Adding asdf init to .zshrc"
    echo -e '\n. $(brew --prefix asdf)/libexec/asdf.sh' >> "$HOME/.zshrc"
fi

# Source asdf for current shell session
. "$(brew --prefix asdf)/libexec/asdf.sh"

# --- asdf plugins for common languages ---
for plugin in nodejs python ruby golang; do
    if ! asdf plugin-list | grep -q $plugin; then
        echo "Adding asdf plugin: $plugin"
        asdf plugin-add $plugin
    fi
done

# --- Symlinks ---
echo "Symlinking dotfiles..."
mkdir -p "$HOME/.config/nvim"
mkdir -p "$HOME/.config/ghostty"
ln -sf "$DOTFILES/.zshrc" "$HOME/.zshrc"
ln -sf "$DOTFILES/.aliases" "$HOME/.aliases"
ln -sf "$DOTFILES/.zsh_profile" "$HOME/.zsh_profile"
ln -sf "$DOTFILES/.vimrc" "$HOME/.vimrc"
ln -sf "$DOTFILES/.tmux.conf" "$HOME/.tmux.conf"
ln -sf "$DOTFILES/.psqlrc" "$HOME/.psqlrc"
ln -sf "$DOTFILES/.gitconfig" "$HOME/.gitconfig"
ln -sf "$DOTFILES/.config/ghostty" "$HOME/.config/ghostty"
if [ -d "$DOTFILES/.config/nvim" ]; then
  for file in "$DOTFILES/.config/nvim/"*; do
    ln -sf "$file" "$HOME/.config/nvim/"
  done
fi

# --- pipx install for Python LSP (pyright) ---
if ! command -v pipx >/dev/null 2>&1; then
    echo "Installing pipx..."
    brew install pipx
    pipx ensurepath
fi
echo "Installing Python LSP (pyright) with pipx..."
pipx install --force pyright

# --- Ruby LSP (using asdf Ruby if available) ---
echo "Installing Ruby LSP (ruby-lsp)..."
if command -v rbenv >/dev/null 2>&1; then
    eval "$(rbenv init -)"
    gem install ruby-lsp
else
    gem install ruby-lsp --user-install
fi

# --- Node LSPs (typescript, bash) ---
echo "Installing Node LSPs (typescript, bash)..."
if ! command -v npm >/dev/null 2>&1; then
    echo "npm not found. Please install Node.js using asdf or Homebrew."
    exit 1
fi
npm install -g typescript typescript-language-server bash-language-server

# --- Go LSP (gopls) ---
echo "Installing Go LSP (gopls)..."
if asdf where golang >/dev/null 2>&1; then
    go install golang.org/x/tools/gopls@latest
else
    brew install gopls
fi

# --- tmux plugin manager ---
if [ ! -d "$HOME/.tmux/plugins/tpm" ]; then
    echo "Installing tmux plugin manager..."
    git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm
else
    echo "tmux plugin manager already installed."
fi

# --- vim-plug for Vim plugin management ---
if [ ! -f "$HOME/.vim/autoload/plug.vim" ]; then
    echo "Installing vim-plug for Vim..."
    curl -fLo "$HOME/.vim/autoload/plug.vim" --create-dirs \
        https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
else
    echo "vim-plug already installed."
fi

echo "All done! Restart your terminal to use the new configuration."
