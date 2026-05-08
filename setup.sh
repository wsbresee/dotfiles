#!/usr/bin/env bash
set -e

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo "==> Starting setup..."

# ── Homebrew ──────────────────────────────────────────────────────────────────
if ! command -v brew &>/dev/null; then
  echo "==> Installing Homebrew..."
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
fi

echo "==> Installing brew packages..."
brew install tmux vim the_silver_searcher jq 2>/dev/null || true
brew install --cask spotify amethyst 2>/dev/null || true

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

# ── TPM ───────────────────────────────────────────────────────────────────────
if [ ! -d ~/.tmux/plugins/tpm ]; then
  echo "==> Installing TPM..."
  git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm
fi

echo "==> Installing tmux plugins..."
~/.tmux/plugins/tpm/scripts/install_plugins.sh 2>/dev/null || true

# ── Vundle ────────────────────────────────────────────────────────────────────
if [ ! -d ~/.vim/bundle/Vundle.vim ]; then
  echo "==> Installing Vundle..."
  git clone https://github.com/VundleVim/Vundle.vim.git ~/.vim/bundle/Vundle.vim
fi

echo "==> Installing vim plugins..."
vim +PluginInstall +qall 2>/dev/null || true

# ── iTerm2 palenight theme ────────────────────────────────────────────────────
echo "==> Downloading palenight iTerm2 theme..."
curl -sL "https://raw.githubusercontent.com/JonathanSpeek/palenight-iterm2/master/palenight.itermcolors" \
  -o ~/Downloads/palenight.itermcolors

echo ""
echo "==> Done!"
echo ""
echo "Manual steps remaining:"
echo "  1. iTerm2: Preferences → Profiles → Colors → Color Presets → Import → ~/Downloads/palenight.itermcolors"
echo "  2. iTerm2: Set background color to black (Preferences → Profiles → Colors → Background)"
echo "  3. Amethyst: Open and grant Accessibility permissions in System Settings"
