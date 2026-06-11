export PATH="/opt/homebrew/bin:$HOME/.local/bin:/usr/local/bin:$PATH"

# pyenv
export PYENV_ROOT="$HOME/.pyenv"
export PATH="$PYENV_ROOT/bin:$PATH"
eval "$(pyenv init -)"

# Auto-attach to tmux when opening iTerm2
if [[ -z "$TMUX" ]] && [[ "$TERM_PROGRAM" == "iTerm.app" ]]; then
  exec tmux new-session -A -s main
fi

export ZSH="$HOME/.oh-my-zsh"
ZSH_THEME="common"
ENABLE_CORRECTION="true"
plugins=(git zsh-autosuggestions)

source $ZSH/oh-my-zsh.sh

# Compute autosuggestions synchronously so the greyed-out suggestion tracks
# the buffer as closely as possible (async can lag a keystroke behind).
unset ZSH_AUTOSUGGEST_USE_ASYNC

# vi mode
export KEYTIMEOUT=40
set -o vi
bindkey -M viins 'jk' vi-cmd-mode

# Accept zsh-autosuggestion with Tab if one is showing; otherwise normal completion.
#
# Re-fetch the suggestion instead of trusting $POSTDISPLAY: when keys arrive
# faster than zle processes them (common here — the jk binding makes zsh hold
# back every j to wait for a possible k), zsh-autosuggestions restores a stale
# suggestion computed for a shorter buffer, and accepting it blindly doubles
# the overlap (proj -> projjects). The leading underscore in the widget name
# is load-bearing: it stops zsh-autosuggestions from wrapping this widget in
# its modify handler, which blanks $POSTDISPLAY before the body runs.
_tab_or_autosuggest() {
  local suggestion
  if [[ -n "$POSTDISPLAY" ]]; then
    _zsh_autosuggest_fetch_suggestion "$BUFFER"
    if (( $#suggestion > $#BUFFER )) && [[ "${suggestion:0:$#BUFFER}" == "$BUFFER" ]]; then
      POSTDISPLAY="${suggestion:$#BUFFER}"
      zle autosuggest-accept
      return
    fi
    POSTDISPLAY=""
  fi
  zle expand-or-complete
}
zle -N _tab_or_autosuggest
bindkey '^I' _tab_or_autosuggest

# Auto-activate/deactivate Python .venv on directory change
_auto_venv() {
  # Walk up from cwd looking for a .venv directory
  local dir="$PWD"
  local venv_dir=""
  while [[ "$dir" != "/" ]]; do
    if [[ -f "$dir/.venv/bin/activate" ]]; then
      venv_dir="$dir/.venv"
      break
    fi
    dir="${dir:h}"   # parent directory (zsh equivalent of dirname)
  done

  if [[ -n "$venv_dir" ]]; then
    # A .venv exists here — activate it if not already active
    if [[ "$VIRTUAL_ENV" != "$venv_dir" ]]; then
      source "$venv_dir/bin/activate"
      echo "🐍 venv: $(python --version 2>&1) (${venv_dir/#$HOME/~})"
    fi
  else
    # No .venv found — deactivate if something is currently active
    if [[ -n "$VIRTUAL_ENV" ]]; then
      deactivate
      echo "🐍 venv: deactivated"
    fi
  fi
}

# Run on every directory change and on new shell startup
autoload -U add-zsh-hook
add-zsh-hook chpwd _auto_venv
_auto_venv   # run once for the shell's starting directory
