UNAME := $(shell uname)
DOT_PATH := $(shell pwd)

vim_dotfiles := $(HOME)/.vimrc
tmux_dotfiles := $(HOME)/.tmux.conf
zsh_dotfiles := $(HOME)/.zshrc $(HOME)/.zsh_profile
git_dotfiles := $(HOME)/.gitconfig

# create sym links
$(HOME)/.%: %
			ln -sf $(DOT_PATH)/$^ $@

vim: $(vim_dotfiles)
tmux: $(tmux_dotfiles)
zsh: $(zsh_dotfiles)
git: $(git_dotfiles)

all: vim zsh git tmux
