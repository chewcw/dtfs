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
