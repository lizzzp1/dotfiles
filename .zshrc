zmodload zsh/zprof

# Path to your oh-my-zsh installation.
export ZSH="$HOME/.oh-my-zsh"

ZSH_THEME="robbyrussell"

plugins=(git)

export EDITOR='nvim'
export VISUAL='nvim'
# Compilation flags
# export ARCHFLAGS="-arch x86_64"

#export PATH="$HOME/.asdf/shims:$PATH"
#. $HOME/.asdf/asdf.sh

# Execute code in the background to not affect the current session
# https://htr3n.github.io/2018/07/faster-zsh/
{
  # Compile zcompdump, if modified, to increase startup speed.
    zcompdump="${ZDOTDIR:-$HOME}/.zcompdump"
      if [[ -s "$zcompdump" && (! -s "${zcompdump}.zwc" || "$zcompdump" -nt "${zcompdump}.zwc") ]]; then
          zcompile "$zcompdump"
            fi
            }

# HISTORY #
# https://registerspill.thorstenball.com/p/which-command-did-you-run-1731-days
HISTFILE=$HOME/.zsh_history
HISTSIZE=50000
SAVEHIST=50000

# Immediately append to history file:
 setopt INC_APPEND_HISTORY
# Record timestamp in history:
 setopt EXTENDED_HISTORY
# # Expire duplicate entries first when trimming history:
 setopt HIST_EXPIRE_DUPS_FIRST
# # Dont record an entry that was just recorded again:
 setopt HIST_IGNORE_DUPS
# # Delete old recorded entry if new entry is a duplicate:
 setopt HIST_IGNORE_ALL_DUPS
# # Do not display a line previously found:
 setopt HIST_FIND_NO_DUPS
# # Dont record an entry starting with a space:
 setopt HIST_IGNORE_SPACE
# # Dont write duplicate entries in the history file:
 setopt HIST_SAVE_NO_DUPS
# # Share history between all sessions:
 setopt SHARE_HISTORY
# # Execute commands using history (e.g.: using !$) immediately:
 unsetopt HIST_VERIFY

ulimit -n

git_prompt_info() {
  local dirstatus=" OK"
  local dirty="%{$fg_bold[red]%} X%{$reset_color%}"

  if [[ ! -z $(git status --porcelain 2> /dev/null | tail -n1) ]]; then
    dirstatus=$dirty
  fi

  ref=$(git symbolic-ref HEAD 2> /dev/null) || \
  ref=$(git rev-parse --short HEAD 2> /dev/null) || return
  echo " %{$fg_bold[green]%}${ref#refs/heads/}$dirstatus%{$reset_color%}"
}
PROMPT='${dir_info}$(git_prompt_info) %(1j.$promptjobs.$promptnormal)'

export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"

del_branches() {
  git branch | grep -v 'main' | grep -v 'dev' | grep -v "$1" | xargs git branch -D
}

export PATH=$PATH:/usr/local/go/bin
export GOPATH=$HOME/go
export GOROOT=/usr/local/go

#zscaler
export CERT_PATH="/Users/$(whoami)/ca_certs/zscaler-custom-ca-bundle.pem"
export CERT_DIR="/Users/$(whoami)/ca_certs/"
export SSL_CERT_FILE=${CERT_PATH}
export SSL_CERT_DIR=${CERT_DIR}
export REQUESTS_CA_BUNDLE=${CERT_PATH} # PIP,
export NODE_EXTRA_CA_CERTS=${CERT_PATH} # NPM
export AWS_CA_BUNDLE=${CERT_PATH}
export PIP_CERT=${CERT_PATH}
export HTTPLIB2_CA_CERTS=${CERT_PATH}
export SSL_CERT_FILE="${CERT_PATH}"
export GAM_CA_FILE=${CERT_PATH}

[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh
[ -f ~/.zsh_files/paths ] && source ~/.zsh_files/paths
[ -f $ZSH/oh-my-zsh.sh ] && source $ZSH/oh-my-zsh.sh
[ -f ~/.aliases ] && source ~/.aliases
[ -f ~/.personal.sh ] && source ~/.personal.sh

export PATH="$HOME/.rbenv/bin:$PATH"
eval "$(rbenv init -)"
