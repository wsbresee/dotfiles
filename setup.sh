#!/usr/bin/env bash
set -e

DOTFILES_REPO="https://github.com/wsbresee/dotfiles"
DOTFILES_DIR="$HOME/projects/dotfiles"

echo "==> Starting setup..."

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
symlink .zshrc

# ── oh-my-zsh ─────────────────────────────────────────────────────────────────
if [ ! -d ~/.oh-my-zsh ]; then
  echo "==> Installing oh-my-zsh..."
  RUNZSH=no CHSH=no sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
fi

echo "==> Installing zsh-autosuggestions..."
if [ ! -d ~/.oh-my-zsh/custom/plugins/zsh-autosuggestions ]; then
  git clone https://github.com/zsh-users/zsh-autosuggestions \
    ~/.oh-my-zsh/custom/plugins/zsh-autosuggestions
fi

echo "==> Installing common theme..."
if [ ! -f ~/.oh-my-zsh/custom/themes/common.zsh-theme ]; then
  curl -sL https://raw.githubusercontent.com/jackharrisonsherlock/common/master/common.zsh-theme \
    -o ~/.oh-my-zsh/custom/themes/common.zsh-theme
fi

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
