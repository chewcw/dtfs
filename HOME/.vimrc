set number
set relativenumber

" set cursor
let &t_SI = "\e[6 q"
let &t_EI = "\e[2 q"

" reset the cursor on start (for older versions of vim, usually not required)
augroup myCmds
au!
autocmd VimEnter * silent !echo -ne "\e[2 q"
augroup END

" highlight color
" https://vi.stackexchange.com/questions/9249/how-do-i-restore-visual-mode-selection-highlighting
:highlight Visual cterm=reverse ctermbg=NONE

if &diff
  colorscheme industry
  set cursorline
  set nonumber
  set norelativenumber
  syntax off

  " https://stackoverflow.com/a/35943892
  set nocp
  let mapleader = " "
  nnoremap <leader>l :diffget LOCAL<CR>
  nnoremap <leader>r :diffget REMOTE<CR>
  nnoremap <leader>b :diffget BASE<CR>
  nnoremap <leader>e :e!<CR>
  nnoremap <leader>q :cq<CR>

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

" https://vim.fandom.com/wiki/Swapping_characters,_words_and_lines
nnoremap <silent> gw "_yiw:s/\(\%#\w\+\)\(\_W\+\)\(\w\+\)/\3\2\1/<CR><c-o><c-l>:nohlsearch<CR>
nnoremap <silent> gl "_yiw?\w\+\_W\+\%#<CR>:s/\(\%#\w\+\)\(\_W\+\)\(\w\+\)/\3\2\1/<CR><c-o><c-l>:nohlsearch<CR>
vnoremap <C-x> <Esc>`.``gv"*d"-P``"*P
