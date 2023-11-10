set number
set relativenumber
set scrolloff=5
set showmatch
set breakindent

" set cursor
let &t_SI = "\e[6 q"
let &t_EI = "\e[2 q"

" reset the cursor on start (for older versions of vim, usually not required)
augroup myCmds
au!
autocmd VimEnter * silent !echo -ne "\e[2 q"
augroup END

" https://stackoverflow.com/a/35943892
set nocp
let mapleader = " "

" highlight color
" https://vi.stackexchange.com/questions/9249/how-do-i-restore-visual-mode-selection-highlighting
:highlight Visual cterm=reverse ctermbg=NONE

nnoremap <leader>e :e!<CR>
nnoremap <leader>q :q!<CR>

if &diff
  colorscheme industry
  set cursorline
  set nonumber
  set norelativenumber
  syntax off

  nnoremap <leader>ggl :diffget LOCAL<CR>
  nnoremap <leader>ggr :diffget REMOTE<CR>
  nnoremap <leader>ggb :diffget BASE<CR>
  nnoremap <leader>ggq :cq<CR>

  " https://vi.stackexchange.com/a/25026
  highlight CursorLine     ctermbg=Black        ctermfg=NONE
  highlight DiffAdd        ctermbg=NONE         ctermfg=DarkCyan
  highlight DiffAdded      ctermbg=NONE         ctermfg=DarkCyan
  highlight DiffChange     ctermbg=NONE         ctermfg=DarkGreen
  highlight DiffChanged    ctermbg=NONE         ctermfg=DarkGreen
  highlight DiffDelete     ctermbg=NONE         ctermfg=DarkRed
  highlight DiffRemoved    ctermbg=NONE         ctermfg=DarkRed
  highlight DiffText       ctermbg=NONE         ctermfg=Yellow
endif

" navigate witihin insert mode
" inoremap h <Left>
" inoremap j <Down>
" inoremap k <Up>
" inoremap l <Right>

" switch between windows
nnoremap <C-h> <C-w>h
nnoremap <C-j> <C-w>j
nnoremap <C-k> <C-w>k
nnoremap <C-l> <C-w>l

" set tab space
nnoremap g4 :set shiftwidth=4 tabstop=4 softtabstop=4 <CR>
nnoremap g2 :set shiftwidth=2 tabstop=2 softtabstop=2 <CR>

" split
" nnoremap \ :vsplit<CR>
" nnoremap _ :split<CR>
" nnoremap - :resize +5 <CR>
" nnoremap = :resize -5 <CR>
" nnoremap ] :vertical resize +5 <CR>
" nnoremap [ :vertical resize -5 <CR>

" marks
nnoremap <leader>m :delmarks a-zA-Z0-9"^.[] <CR>

" clear highlights
nnoremap <leader>n :nohl <CR>

" insert new line above
" inoremap  <C-o>O
" nnoremap <A-CR> O<Esc>

" wrap
nnoremap <leader>lw  :set wrap! <CR>
nnoremap <leader>lW  :windo set wrap! <CR>

" macro
nnoremap - @@

" https://vim.fandom.com/wiki/Swapping_characters,_words_and_lines
nnoremap <silent> gw "_yiw:s/\(\%#\w\+\)\(\_W\+\)\(\w\+\)/\3\2\1/<CR><c-o><c-l>:nohlsearch<CR>
nnoremap <silent> gl "_yiw?\w\+\_W\+\%#<CR>:s/\(\%#\w\+\)\(\_W\+\)\(\w\+\)/\3\2\1/<CR><c-o><c-l>:nohlsearch<CR>
vnoremap <C-x> <Esc>`.``gv"*d"-P``"*P
