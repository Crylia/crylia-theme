export ZSH="$HOME/.oh-my-zsh"

ZSH_THEME="robbyrussell"
ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE=6

plugins=(git zsh-autosuggestions)

source $ZSH/oh-my-zsh.sh

alias spicetify=/home/crylia/.spicetify/spicetify

eval "$(starship init zsh)"
