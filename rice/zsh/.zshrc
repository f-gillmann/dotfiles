export ZSH="$HOME/.oh-my-zsh"
export EDITOR="nvim"
export SUDO_EDITOR="$EDITOR"
export PATH="$PATH:$HOME/.local/bin"

ZSH_THEME="robbyrussell"
HISTFILE=~/.histfile
HISTSIZE=1500
SAVEHIST=5000

plugins=(git)

source $ZSH/oh-my-zsh.sh
