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
