call plug#begin('~/AppData/Local/nvim/plugged')
Plug 'vim-airline/vim-airline'
Plug 'vim-airline/vim-airline-themes'
Plug 'neoclide/coc.nvim', { 'branch': 'release' }
Plug 'sheerun/vim-polyglot'
Plug 'machakann/vim-sandwich'
Plug 'scrooloose/nerdtree', { 'on': 'NERDTreeToggle' }
Plug 'tpope/vim-commentary'
Plug 'tpope/vim-surround', { 'branch': 'master' }
Plug 'junegunn/fzf', {'do': { -> fzf#install() } }
Plug 'junegunn/fzf.vim'
Plug 'gelguy/wilder.nvim', {'do': ':UpdateRemotePlugins'}
Plug 'sindrets/winshift.nvim' 
Plug 'arcticicestudio/nord-vim'
Plug 'OmniSharp/omnisharp-vim'
Plug 'dense-analysis/ale'
call plug#end()

" color scheme
syntax enable
set termguicolors
colorscheme nord

" some rules not related to plugins
set list
set listchars=tab:▶\ ,trail:·
set relativenumber
set foldmethod=indent
set foldlevel=99
set nu rnu
set nowrap
set mouse=n
set notimeout
set ttimeout
nmap <leader>n :nohl<CR>
nnoremap <silent> <C-t> :tabnew<CR>
nnoremap <silent> <A-.> gt
nnoremap <silent> <A-,> gT
nnoremap <silent> <C-H> :wincmd h<CR>
nnoremap <silent> <C-J> :wincmd j<CR>
nnoremap <silent> <C-K> :wincmd k<CR>
nnoremap <silent> <C-L> :wincmd l<CR>
nnoremap <A-=> :resize +5<CR>
nnoremap <A--> :resize -5<CR>
nnoremap <A-]> :vertical resize +5<CR>
nnoremap <A-[> :vertical resize -5<CR>
nnoremap <C-\> :vsplit<CR>
nnoremap <C-_> :split<CR>

" Conquer of Completion
inoremap <expr> <Tab> pumvisible() ? "\<C-n>" : "\<Tab>"
inoremap <expr> <S-Tab> pumvisible() ? "\<C-p>" : "\<S-Tab>"
inoremap <silent><expr> <C-space> coc#refresh()
nmap <leader>g <C-o>
nmap <silent> gd <Plug>(coc-definition)
nmap <silent> gD :call CocAction('jumpDefinition', 'vsplit')<CR>
nmap <silent> gh <Plug>(coc-type-definition)
nmap <silent> gi <Plug>(coc-implementation)
nmap <silent> gr <Plug>(coc-references)
nmap <silent> gn <Plug>(coc-rename)
nnoremap <silent> <space>d :<C-u>CocList diagnostics<cr>
nnoremap <silent> <space>e :<C-u>CocList extensions<cr>
nmap <silent> [g <Plug>(coc-diagnostic-prev)
nmap <silent> ]g <Plug>(coc-diagnostic-next)
nmap <leader>f  <Plug>(coc-format-selected)
nmap <leader>a  <Plug>(coc-codeaction-selected)
nmap <leader>qf  <Plug>(coc-fix-current)
autocmd CursorHold * silent call CocActionAsync('highlight')

" NERDTree
nnoremap <C-n> :NERDTreeToggle<CR>
let NERDTreeMapActivateNode='<space>'
let NERDTreeShowHidden=1

" FZF
nnoremap <C-p> :FZF

" highlight color
" https://vi.stackexchange.com/questions/9249/how-do-i-restore-visual-mode-selection-highlighting
:highlight Visual cterm=reverse ctermbg=NONE

" gelguy/wilder.nvim
call wilder#setup({ 
	\ 'modes': [':', '/', '?'],
	\ 'next_key': '<C-l>',
	\ 'previous_key': '<C-h>',
	\ 'accept_key': '<C-j>',
	\ 'reject_key': '<C-k>',
	\ })

call wilder#set_option('renderer', wilder#wildmenu_renderer(
	\ wilder#wildmenu_airline_theme({
	\ 'highlights': {},
	\ 'highlighter': wilder#basic_highlighter(),
	\ 'separator': ' . ',
	\ })))

" sindrets/winshift.nvim
nnoremap <C-A-H> <Cmd>WinShift left<CR>
nnoremap <C-A-J> <Cmd>WinShift down<CR>
nnoremap <C-A-K> <Cmd>WinShift up<CR>
nnoremap <C-A-L> <Cmd>WinShift right<CR>

" Omnisharp
if has('patch-8.1.1880')
  set completeopt=longest,menuone,popuphidden
  set completepopup=highlight:Pmenu,border:off
else
  set completeopt=longest,menuone,preview
  set previewheight=5
endif
let g:ale_linters = { 'cs': ['OmniSharp'] }

augroup omnisharp_commands
  autocmd!
  autocmd CursorHold *.cs OmniSharpTypeLookup
  autocmd FileType cs nmap <silent> <buffer> <Leader>osgd <Plug>(omnisharp_go_to_definition)
  autocmd FileType cs nmap <silent> <buffer> <Leader>osfu <Plug>(omnisharp_find_usages)
  autocmd FileType cs nmap <silent> <buffer> <Leader>osfi <Plug>(omnisharp_find_implementations)
  autocmd FileType cs nmap <silent> <buffer> <Leader>ospd <Plug>(omnisharp_preview_definition)
  autocmd FileType cs nmap <silent> <buffer> <Leader>ospi <Plug>(omnisharp_preview_implementations)
  autocmd FileType cs nmap <silent> <buffer> <Leader>ost <Plug>(omnisharp_type_lookup)
  autocmd FileType cs nmap <silent> <buffer> <Leader>osd <Plug>(omnisharp_documentation)
  autocmd FileType cs nmap <silent> <buffer> <Leader>osfs <Plug>(omnisharp_find_symbol)
  autocmd FileType cs nmap <silent> <buffer> <Leader>osfx <Plug>(omnisharp_fix_usings)
  autocmd FileType cs nmap <silent> <buffer> [[ <Plug>(omnisharp_navigate_up)
  autocmd FileType cs nmap <silent> <buffer> ]] <Plug>(omnisharp_navigate_down)
  autocmd FileType cs nmap <silent> <buffer> <Leader>osgcc <Plug>(omnisharp_global_code_check)
  autocmd FileType cs nmap <silent> <buffer> <Leader>osca <Plug>(omnisharp_code_actions)
  autocmd FileType cs xmap <silent> <buffer> <Leader>osca <Plug>(omnisharp_code_actions)
  autocmd FileType cs nmap <silent> <buffer> <Leader>os. <Plug>(omnisharp_code_action_repeat)
  autocmd FileType cs xmap <silent> <buffer> <Leader>os. <Plug>(omnisharp_code_action_repeat)
  autocmd FileType cs nmap <silent> <buffer> <Leader>os= <Plug>(omnisharp_code_format)
  autocmd FileType cs nmap <silent> <buffer> <Leader>osnm <Plug>(omnisharp_rename)
  autocmd FileType cs nmap <silent> <buffer> <Leader>osre <Plug>(omnisharp_restart_server)
  autocmd FileType cs nmap <silent> <buffer> <Leader>osst <Plug>(omnisharp_start_server)
  autocmd FileType cs nmap <silent> <buffer> <Leader>ossp <Plug>(omnisharp_stop_server)
augroup END
