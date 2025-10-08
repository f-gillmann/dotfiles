export ZSH="$HOME/.oh-my-zsh"
export EDITOR="vim"
export SUDO_EDITOR="$EDITOR"
export PATH="$PATH:$HOME/.local/bin"

ZSH_THEME="robbyrussell"
plugins=(git zsh-syntax-highlighting fast-syntax-highlighting)
HISTFILE=~/.histfile
HISTSIZE=1500
SAVEHIST=5000

source $ZSH/oh-my-zsh.sh

pfetch

eval "$(oh-my-posh init zsh --config ~/.omp.json)"
