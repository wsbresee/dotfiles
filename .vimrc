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
let g:NERDTreeNodeDelimiter = " "
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
