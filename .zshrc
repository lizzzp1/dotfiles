zmodload zsh/zprof
source ~/.zsh_profile

# If you come from bash you might have to change your $PATH.
 export PATH=$HOME/bin:/usr/local/bin:$PATH

# Path to your oh-my-zsh installation.
export ZSH="$HOME/.oh-my-zsh"

ZSH_THEME="robbyrussell"

plugins=(git)

local private="${HOME}/.zsh.d/private.sh"
if [ -e ${private} ]; then
	  . ${private}
fi

export EDITOR='nvim'
export VISUAL='nvim'
# Compilation flags
# export ARCHFLAGS="-arch x86_64"

export PATH="$HOME/.rbenv/shims:$PATH"
# export LEFTHOOK_BIN="/Users/lizpineda/.rbenv/shims/lefthook"
#

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

source /Users/lizpineda/.docker/init-zsh.sh || true # Added by Docker Desktop

ulimit -n

export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm

del_branches() {
  git branch | grep -v 'main' | grep -v 'dev' | grep -v "$1" | xargs git branch -D
}


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

export PATH="$HOME/.rbenv/bin:$PATH"
eval "$(rbenv init -)"
