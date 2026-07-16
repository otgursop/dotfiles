#
# ~/.zshrc
#

# PATH
export PATH=$HOME/bin:$HOME/.local/bin:/usr/local/bin:$PATH

# ZSH path
export ZSH="$HOME/.oh-my-zsh"

# ZSH_COMPDUMP
export ZSH_COMPDUMP=$ZSH/cache/.zcompdump-$HOST

# Update check
zstyle ':omz:update' mode disabled

# Theme
ZSH_THEME="eastwood"
ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE="fg=#a89984,underline"

# Plugins
plugins=(git)

source $ZSH/oh-my-zsh.sh

# Preferred editor for local and remote sessions
if [[ -n $SSH_CONNECTION ]]; then
   export EDITOR='vim'
 else
   export EDITOR='nvim'
 fi

#####################
# ALIASES
#####################

alias ls="lsd"
alias cd="z"
alias cat="bat"

alias sl="cd ~/.local/sl/"
alias wl="cd ~/.local/wl"
alias cdc="cd ~/code/c/"
alias cdp="cd ~/code/cpp/"

#####################
### SETTINGS
#####################

eval "$(zoxide init zsh)"

#####################
### PLUGINS (from pacman)
#####################

source /usr/share/zsh/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
source /usr/share/zsh/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh

#####################
### OTHER
#####################
# ...
