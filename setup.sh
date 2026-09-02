#!/usr/bin/env bash
set -e

DOTFILES_REPO="https://github.com/wsbresee/dotfiles"
DOTFILES_DIR="$HOME/projects/dotfiles"

# ── Options ───────────────────────────────────────────────────────────────────
# --no-apps skips everything that touches a GUI app or drops files outside the
# dotfiles/CLI world: Homebrew casks (Amethyst et al.) and the iTerm2 prefs.
# Handy on a work machine, in a VM, or over SSH where /Applications is off limits.
SKIP_APPS="${SKIP_APPS:-0}"
ITERM_WAS_RUNNING=0

usage() {
  cat <<'USAGE'
Usage: setup.sh [--no-apps]

  --no-apps   Skip GUI app installs (Homebrew casks) and the iTerm2
              preferences import. CLI tools, dotfile symlinks, oh-my-zsh,
              TPM and Vundle are still set up. Same as SKIP_APPS=1 setup.sh
  -h, --help  Show this help
USAGE
}

while [ $# -gt 0 ]; do
  case "$1" in
    --no-apps|--skip-apps) SKIP_APPS=1 ;;
    -h|--help) usage; exit 0 ;;
    *) echo "Unknown option: $1" >&2; usage >&2; exit 1 ;;
  esac
  shift
done

echo "==> Starting setup..."
if [ "$SKIP_APPS" = 1 ]; then
  echo "==> --no-apps: skipping GUI app installs"
fi

# ── Clone or update dotfiles repo ────────────────────────────────────────────
if [ ! -d "$DOTFILES_DIR/.git" ]; then
  echo "==> Cloning dotfiles..."
  git clone "$DOTFILES_REPO" "$DOTFILES_DIR"
else
  echo "==> Updating dotfiles..."
  git -C "$DOTFILES_DIR" pull --ff-only
fi

# ── Homebrew ──────────────────────────────────────────────────────────────────
if ! command -v brew &>/dev/null; then
  echo "==> Installing Homebrew..."
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
fi

brew_install()      { brew list --formula "$1" &>/dev/null || brew install "$1"; }
brew_cask_install() {
  if [ "$SKIP_APPS" = 1 ]; then
    echo "    Skipping cask $1 (--no-apps)"
    return 0
  fi
  brew list --cask "$1" &>/dev/null || brew install --cask "$1"
}

echo "==> Installing brew packages..."
brew_install tmux
brew_install vim
brew_install the_silver_searcher
brew_install jq
brew_cask_install amethyst

# ── Symlink dotfiles ──────────────────────────────────────────────────────────
echo "==> Symlinking dotfiles..."
symlink() {
  local src="$DOTFILES_DIR/$1"
  local dst="$HOME/$1"
  if [ -e "$dst" ] && [ ! -L "$dst" ]; then
    mv "$dst" "$dst.bak"
    echo "    Backed up existing $dst → $dst.bak"
  fi
  ln -sf "$src" "$dst"
  echo "    $dst → $src"
}

symlink .tmux.conf
symlink .vimrc
symlink .zshrc

# ── oh-my-zsh ─────────────────────────────────────────────────────────────────
if [ ! -d ~/.oh-my-zsh ]; then
  echo "==> Installing oh-my-zsh..."
  RUNZSH=no CHSH=no sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
fi

if [ ! -d ~/.oh-my-zsh/custom/plugins/zsh-autosuggestions ]; then
  echo "==> Installing zsh-autosuggestions..."
  git clone https://github.com/zsh-users/zsh-autosuggestions \
    ~/.oh-my-zsh/custom/plugins/zsh-autosuggestions
fi

if [ ! -f ~/.oh-my-zsh/custom/themes/common.zsh-theme ]; then
  echo "==> Installing common theme..."
  curl -sL https://raw.githubusercontent.com/jackharrisonsherlock/common/master/common.zsh-theme \
    -o ~/.oh-my-zsh/custom/themes/common.zsh-theme
fi

# ── TPM ───────────────────────────────────────────────────────────────────────
if [ ! -d ~/.tmux/plugins/tpm ]; then
  echo "==> Installing TPM..."
  git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm
fi

if [ "$(ls ~/.tmux/plugins | wc -l)" -le 1 ]; then
  echo "==> Installing tmux plugins..."
  ~/.tmux/plugins/tpm/scripts/install_plugins.sh 2>/dev/null || true
fi

# ── Vundle ────────────────────────────────────────────────────────────────────
if [ ! -d ~/.vim/bundle/Vundle.vim ]; then
  echo "==> Installing Vundle..."
  git clone https://github.com/VundleVim/Vundle.vim.git ~/.vim/bundle/Vundle.vim
fi

if [ "$(ls ~/.vim/bundle | wc -l)" -le 1 ]; then
  echo "==> Installing vim plugins..."
  vim +PluginInstall +qall 2>/dev/null || true
fi

# ── iTerm2 preferences ────────────────────────────────────────────────────────
# The exported plist carries the whole setup: palenight colors, black
# background, Monaco 12, keybindings, profiles. No manual import needed.
ITERM_PLIST="$DOTFILES_DIR/iterm2/com.googlecode.iterm2.plist"
ITERM_LIVE="$HOME/Library/Preferences/com.googlecode.iterm2.plist"

if [ "$SKIP_APPS" = 0 ] && [ -f "$ITERM_PLIST" ]; then
  if pgrep -x iTerm2 >/dev/null 2>&1; then
    # iTerm2 rewrites its prefs from memory on quit, which would silently
    # undo the import. Don't touch them while it's running.
    ITERM_WAS_RUNNING=1
    echo "==> iTerm2 is running — skipping preferences import."
    echo "    Quit iTerm2 and re-run this script (or run it from Terminal.app)."
  else
    echo "==> Importing iTerm2 preferences..."
    if [ -f "$ITERM_LIVE" ] && [ ! -f "$ITERM_LIVE.bak" ]; then
      cp "$ITERM_LIVE" "$ITERM_LIVE.bak"
      echo "    Backed up existing prefs → $ITERM_LIVE.bak"
    fi
    defaults import com.googlecode.iterm2 "$ITERM_PLIST"
    # cfprefsd caches prefs; without this the import is lost on next read.
    killall cfprefsd 2>/dev/null || true
    echo "    Imported. Colors, font and keybindings are set."
  fi
fi

echo ""
echo "==> Done!"
echo ""
if [ "$SKIP_APPS" = 1 ]; then
  echo "GUI app setup was skipped (--no-apps); no manual steps remaining."
else
  echo "Manual steps remaining:"
  if [ "$ITERM_WAS_RUNNING" = 1 ]; then
    echo "  - iTerm2: quit it and re-run this script to apply the saved preferences"
  fi
  echo "  - Amethyst: open it and grant Accessibility permissions in System Settings"
fi
