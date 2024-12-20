DOT_PATH := $(shell pwd)

git_dotfiles := $(HOME)/.gitconfig
psql_dotfiles := $(HOME)/.psqlrc
tmux_dotfiles := $(HOME)/.tmux.conf
vim_dotfiles := $(HOME)/.vimrc
nvim_dotfiles := $(HOME)/.config/nvim/init.vim
zsh_dotfiles := $(HOME)/.zshrc $(HOME)/.zsh_profile

$(HOME)/.%: %
	ln -sf $(DOT_PATH)/$^ $@

git: $(git_dotfiles)
psql: $(psql_dotfiles)
tmux: $(tmux_dotfiles)
vim: $(vim_dotfiles)
nvim: $(vim_dotfiles)
zsh: $(zsh_dotfiles)

all: vim nvim zsh git tmux psql
