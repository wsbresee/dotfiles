#!/usr/bin/env bash
set -e

echo "==> Starting setup..."

# ── Homebrew ──────────────────────────────────────────────────────────────────
if ! command -v brew &>/dev/null; then
  echo "==> Installing Homebrew..."
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
fi

echo "==> Installing brew packages..."
brew install tmux vim the_silver_searcher jq 2>/dev/null || true
brew install --cask spotify amethyst 2>/dev/null || true

# ── tmux config ───────────────────────────────────────────────────────────────
echo "==> Writing ~/.tmux.conf..."
cat > ~/.tmux.conf << 'EOF'
set -g status-keys vi
setw -g mode-keys vi
setw -g monitor-activity off

# Prefix: C-a
unbind C-b
set-option -g prefix C-a
bind-key C-a send-prefix

# Splits
bind \\ split-window -h
bind - split-window -v
bind v split-window -h
bind s split-window -v
unbind '"'
unbind %

# Pane resize (with prefix)
bind-key J resize-pane -D 15
bind-key K resize-pane -U 15
bind-key H resize-pane -L 15
bind-key L resize-pane -R 15
bind-key M-j resize-pane -D
bind-key M-k resize-pane -U
bind-key M-h resize-pane -L
bind-key M-l resize-pane -R

# Vim-style pane selection (with prefix)
bind h select-pane -L
bind j select-pane -D
bind k select-pane -U
bind l select-pane -R

# Alt+vim keys to switch panes (no prefix)
bind -n M-h select-pane -L
bind -n M-j select-pane -D
bind -n M-k select-pane -U
bind -n M-l select-pane -R
bind -n M-Left select-pane -L
bind -n M-Right select-pane -R
bind -n M-Up select-pane -U
bind -n M-Down select-pane -D

# Window navigation (no prefix)
bind -n M-n previous-window
bind -n M-m next-window
bind -n C-n next-window
bind -n C-u previous-window

# Misc
set -sg escape-time 0
bind r source-file ~/.tmux.conf

# Terminal (true color)
set -g default-terminal "tmux-256color"
set-option -sa terminal-overrides ",xterm*:Tc"

# Status bar (palenight colors)
set -g status-interval 1
set -g status on
set -g status-justify centre
set -g status-style 'bg=default,fg=default'
set -g status-position top
set -g status-left-length 80
set -g status-right-length 80
set -g status-left "#[fg=#c792ea,bg=default]#S#[fg=#697098,bg=default]"
set -g status-right " #[fg=#c792ea,bg=default] %I:%M %p "
set -g window-status-format "#[fg=#697098,bg=default]#I #W"
set -g window-status-current-format "#[fg=#c792ea,bg=default,bold]#I #W"
set -g window-status-separator "#[fg=#697098,bg=default] | "

# Smart pane switching aware of vim splits (vim-tmux-navigator)
is_vim="ps -o state= -o comm= -t '#{pane_tty}' \
    | grep -iqE '^[^TXZ ]+ +(\S+\/)?g?(view|n?vim?x?)(diff)?$'"
bind-key -n 'C-h' if-shell "$is_vim" 'send-keys C-h' 'select-pane -L'
bind-key -n 'C-j' if-shell "$is_vim" 'send-keys C-j' 'select-pane -D'
bind-key -n 'C-k' if-shell "$is_vim" 'send-keys C-k' 'select-pane -U'
bind-key -n 'C-l' if-shell "$is_vim" 'send-keys C-l' 'select-pane -R'
bind-key -T copy-mode-vi 'C-h' select-pane -L
bind-key -T copy-mode-vi 'C-j' select-pane -D
bind-key -T copy-mode-vi 'C-k' select-pane -U
bind-key -T copy-mode-vi 'C-l' select-pane -R

# Vi copy mode
bind-key -T copy-mode-vi 'v' send-keys -X begin-selection
bind-key -T copy-mode-vi 'y' send-keys -X copy-pipe-and-cancel 'pbcopy'

# Plugins
set -g @plugin 'tmux-plugins/tpm'
set -g @plugin 'tmux-plugins/tmux-sensible'
set -g @plugin 'tmux-plugins/tmux-yank'

run -b '~/.tmux/plugins/tpm/tpm'
EOF

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

# ── .vimrc ────────────────────────────────────────────────────────────────────
echo "==> Writing ~/.vimrc..."
cat > ~/.vimrc << 'EOF'
set nocompatible
filetype off

" Vundle
set rtp+=~/.vim/bundle/Vundle.vim
call vundle#begin()

Plugin 'VundleVim/Vundle.vim'

" Navigation
Plugin 'ctrlpvim/ctrlp.vim'
Plugin 'scrooloose/nerdtree'
Plugin 'easymotion/vim-easymotion'
Plugin 'mileszs/ack.vim'
Plugin 'airblade/vim-rooter'
Plugin 'majutsushi/tagbar'

" Editing
Plugin 'tomtom/tcomment_vim'
Plugin 'tpope/vim-surround'
Plugin 'godlygeek/tabular'
Plugin 'ervandew/supertab'
Plugin 'qpkorr/vim-bufkill'
Plugin 'terryma/vim-multiple-cursors'
Plugin 'scrooloose/nerdcommenter'

" Completion & snippets
Plugin 'honza/vim-snippets'
Plugin 'shougo/vimproc.vim'

" UI
Plugin 'luochen1990/rainbow'
Plugin 'bronson/vim-trailing-whitespace'
Plugin 'drewtempelmeyer/palenight.vim'
Plugin 'itchyny/lightline.vim'
Plugin 'mhinz/vim-startify'
Plugin 'joeytwiddle/sexy_scroller.vim'

" Git
Plugin 'tpope/vim-fugitive'

" tmux
Plugin 'benmills/vimux'
Plugin 'christoomey/vim-tmux-navigator'
Plugin 'jgdavey/tslime.vim'

" Utility
Plugin 'tomtom/tlib_vim'
Plugin 'marcweber/vim-addon-mw-utils'

call vundle#end()
filetype plugin indent on

""""""""""""""
"  Colors    "
""""""""""""""

syntax on

let &t_8f = "\<Esc>[38;2;%lu;%lu;%lum"
let &t_8b = "\<Esc>[48;2;%lu;%lu;%lum"

set termguicolors
colorscheme palenight

let g:palenight_terminal_italics=1
let g:lightline = {'colorscheme': 'palenight'}

hi Normal guibg=NONE ctermbg=NONE

""""""""""""""""
"  General     "
""""""""""""""""

set tags=TAGS;/
set notimeout
set clipboard=unnamed
set backspace=indent,eol,start
set belloff=all
set number
set relativenumber
set nowrap
set tw=0
set noshowmode
set smartcase
set smarttab
set smartindent
set autoindent
set softtabstop=4
set shiftwidth=4
set expandtab
set incsearch
set mouse=a
set history=1000
set laststatus=2

let mapleader=" "

" jk to escape
imap jk <Esc>

" Movement
nnoremap - $

" Move lines
nmap mj :m +1<CR>
nmap mk :m -2<CR>

" Clipboard
vmap <Leader>y "+y
vmap <Leader>py "+y
nmap <Leader>pp "+p<Esc>

" Vimrc
map <Leader>pr :so $MYVIMRC<CR>
nnoremap <Leader>pv :edit ~/.vimrc<CR>

" Write/quit
nnoremap <Leader>pw :w<CR>
nnoremap <Leader>pq :q<CR>

" Cursor highlight on insert mode
autocmd InsertEnter,InsertLeave * set cul!

" Quickfix
autocmd BufReadPost quickfix nnoremap <buffer> <CR> <CR>:ccl<CR>
autocmd BufReadPost quickfix nnoremap <buffer> <Leader>j <CR>
autocmd FileType qf wincmd J

" JSON
nmap =j :%!jq<CR>
nnoremap <Leader>fj :%!jq<CR>

" Whitespace
nnoremap <Leader>fw :FixWhitespace<CR>

""""""""""""""""
"  Windows     "
""""""""""""""""

nnoremap <Leader>wh <C-W><C-H>
nnoremap <Leader>wj <C-W><C-J>
nnoremap <Leader>wk <C-W><C-K>
nnoremap <Leader>wl <C-W><C-L>
nnoremap <Leader>wcj <C-W><C-J>:q<CR>
nnoremap <Leader>wo :wincmd p<CR>
nnoremap <Leader>wtl :vsplit<CR>:vertical resize -25<CR>
nnoremap <Leader>wtj :split<CR>:horizontal resize -25<CR>

" Tabs
map <leader>tq :tabclose<CR>
noremap <silent><Leader>t] <C-w><C-]><C-w>T
noremap <silent><Leader>tp <C-w>}
noremap <silent><Leader>to <C-w>z

""""""""""""""""
"  Plugins     "
""""""""""""""""

"" NERDTree
map <Leader>n :NERDTreeToggle<CR>
let NERDTreeIgnore = ['\.pyc$']
let g:NERDTreeNodeDelimiter = " "
let NERDTreeShowHidden=1
let NERDTreeShowLineNumbers=1
autocmd FileType nerdtree setlocal relativenumber

"" CtrlP
map <Leader>pf :CtrlP<CR>
map <Leader>pb :CtrlPBuffer<CR>
map <leader>pt :CtrlPTag<CR>
let g:ctrlp_custom_ignore = '\v[\/](dist|docs)$'
let g:ctrlp_reuse_window = 1
set wildignore+=*/build,*/dist,*/docs,*/.git,*/.cabal-sandbox

"" ACK
let g:ackprg = 'ag --nogroup --nocolor --column'

"" SuperTab
let g:SuperTabDefaultCompletionType = "<c-p>"
if has("gui_running")
  imap <c-space> <c-r>=SuperTabAlternateCompletion("\<lt>c-x>\<lt>c-o>")<cr>
elseif has("unix")
  inoremap <Nul> <c-r>=SuperTabAlternateCompletion("\<lt>c-x>\<lt>c-o>")<cr>
endif

"" Tabular
vmap a= :Tabularize /=<CR>
vmap a: :Tabularize /::<CR>
vmap a- :Tabularize /-><CR>
vmap ac :Tabularize /--<CR>
vmap aa :Tabularize /as<CR>
vmap a( :Tabularize /(<CR>

"" Vimux
let g:tslime_always_current_session = 1
let g:tslime_always_current_window = 1
nnoremap <Leader>of :VimuxPromptCommand()<CR>
nnoremap <Leader>oi :VimuxInterruptRunner<CR>
nnoremap <Leader>ld :w<CR>:VimuxPromptCommand(":r")<CR><CR>

"" Sexy Scroller
let g:SexyScroller_EasingStyle = 0
let g:SexyScroller_MaxTime = 170

"" Rooter
let g:rooter_patterns = ['.git/']

"" Rainbow
let g:rainbow_active = 0

""""""""""""""""""""""""
"  Vimrc Folding       "
""""""""""""""""""""""""

function! VimFolds(lnum)
  let s:thisline = getline(a:lnum)
  if match(s:thisline, '^"" ') >= 0
    return '>2'
  endif
  if match(s:thisline, '^""" ') >= 0
    return '>3'
  endif
  if line(a:lnum) + 2 > line('$')
    return '='
  endif
  let s:line_1_after = getline(a:lnum+1)
  let s:line_2_after = getline(a:lnum+2)
  if (match(s:thisline, '^"""""') >= 0) &&
     \ (match(s:line_1_after, '^"  ') >= 0) &&
     \ (match(s:line_2_after, '^""""') >= 0)
    return '>1'
  endif
  return '='
endfunction

augroup fold_vimrc
  autocmd!
  autocmd FileType vim
    \ setlocal foldmethod=expr |
    \ setlocal foldexpr=VimFolds(v:lnum)
augroup END
EOF

# ── Vim plugins ───────────────────────────────────────────────────────────────
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
