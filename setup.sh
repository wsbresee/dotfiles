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

brew_install()      { brew list --formula "$1" &>/dev/null || brew install "$1"; }
brew_cask_install() { brew list --cask    "$1" &>/dev/null || brew install --cask "$1"; }

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

# ── iTerm2 palenight theme ────────────────────────────────────────────────────
if [ ! -f ~/Downloads/palenight.itermcolors ]; then
  echo "==> Downloading palenight iTerm2 theme..."
  curl -sL "https://raw.githubusercontent.com/JonathanSpeek/palenight-iterm2/master/palenight.itermcolors" \
    -o ~/Downloads/palenight.itermcolors
fi

echo ""
echo "==> Done!"
echo ""
echo "Manual steps remaining:"
echo "  1. iTerm2: Preferences → Profiles → Colors → Color Presets → Import → ~/Downloads/palenight.itermcolors"
echo "  2. iTerm2: Set background color to black (Preferences → Profiles → Colors → Background)"
echo "  3. Amethyst: Open and grant Accessibility permissions in System Settings"
