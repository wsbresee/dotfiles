export PATH="/opt/homebrew/bin:$HOME/.local/bin:/usr/local/bin:$PATH"

# Auto-attach to tmux when opening iTerm2
if [[ -z "$TMUX" ]] && [[ "$TERM_PROGRAM" == "iTerm.app" ]]; then
  exec tmux new-session -A -s main
fi

export ZSH="$HOME/.oh-my-zsh"
ZSH_THEME="common"
ENABLE_CORRECTION="true"
plugins=(git zsh-autosuggestions)

source $ZSH/oh-my-zsh.sh

# vi mode
export KEYTIMEOUT=40
set -o vi
bindkey -M viins 'jk' vi-cmd-mode

# Accept zsh-autosuggestion with Tab if one is showing; otherwise normal completion
_tab_or_autosuggest() {
  if [[ -n "$POSTDISPLAY" ]]; then
    zle autosuggest-accept
  else
    zle expand-or-complete
  fi
}
zle -N _tab_or_autosuggest
bindkey '^I' _tab_or_autosuggest
