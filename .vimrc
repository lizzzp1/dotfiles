runtime macros/matchit.vim
set number
set showmode
set spell spelllang=en
set history=10000
set noswapfile
set rtp+=/opt/homebrew/opt/fz
set report=0 " Always report changed lines
set autowrite " Save buffer changes to disk
set omnifunc=ale#completion#OmniFunc
set tags=tags;/
set relativenumber
set hlsearch " Highlight search matches
set incsearch " Start searching while typing
set ignorecase " Case insensitive searches...
set smartcase

filetype on
filetype indent on

" remap leader to space
let mapleader = " "

cnoremap %% <C-R>=expand('%:h').'/'<cr>
map <leader>e :edit %%
map <leader>v :view %%
map <leader>m :vsplit %%
map <leader>n :split %%

" split navigation
nnoremap <C-J> <C-W><C-J>
nnoremap <C-K> <C-W><C-K>
nnoremap <C-L> <C-W><C-L>
nnoremap <C-H> <C-W><C-H>

" Map Ctrl-a h to navigate, so it matches tmux
nnoremap <C-a>h :wincmd h<CR>
nnoremap <C-a>j :wincmd j<CR>
nnoremap <C-a>k :wincmd k<CR>
nnoremap <C-a>l :wincmd l<CR>

autocmd FileType ruby setlocal expandtab shiftwidth=2 tabstop=2
autocmd FileType eruby setlocal expandtab shiftwidth=2 tabstop=2
autocmd FileType ruby,eruby let g:rubycomplete_buffer_loading = 1
autocmd FileType ruby,eruby let g:rubycomplete_classes_in_global = 1
autocmd FileType ruby,eruby let g:rubycomplete_rails = 1
autocmd FileType json,html,yaml set tabstop=2
autocmd FileType typescript setlocal formatprg=prettier\ --parser\ typescript
autocmd FileType go setlocal shiftwidth=2
autocmd FileType go setlocal softtabstop=2
autocmd FileType go setlocal expandtab

" so gf knows about rb files
augroup rubypath
  autocmd!
  autocmd FileType ruby setlocal suffixesadd+=.rb
augroup END
autocmd FileType ruby setlocal path+=lib

call plug#begin(has('nvim') ? stdpath('data') . '/plugged' : '~/.vim/plugged')

Plug 'junegunn/vim-easy-align'
Plug 'vim-ruby/vim-ruby'
Plug 'tpope/vim-rails'
Plug 'tpope/vim-commentary'
Plug 'tpope/vim-dispatch'
Plug 'tpope/vim-fugitive'
Plug 'tpope/vim-unimpaired'
Plug 'preservim/nerdtree'
Plug 'jlanzarotta/bufexplorer'
Plug 'jremmen/vim-ripgrep'
Plug 'dense-analysis/ale'
Plug 'AndrewRadev/splitjoin.vim'
Plug 'ayu-theme/ayu-vim'
Plug 'itchyny/lightline.vim'
Plug 'vim-test/vim-test'
Plug 'jacoborus/tender.vim'
Plug 'neoclide/coc.nvim', {'branch': 'release'}
Plug 'nvim-telescope/telescope-fzf-native.nvim', { 'do': 'cmake -S. -Bbuild -DCMAKE_BUILD_TYPE=Release && cmake --build build --config Release && cmake --install build --prefix build' }
Plug 'nvim-lua/plenary.nvim'
Plug 'nvim-telescope/telescope.nvim', { 'tag': '0.1.6' }
call plug#end()

" tender plugin
if (has("termguicolors"))
 set termguicolors
endif

syntax enable
colorscheme tender

function! GitStatus()
  let [a,m,r] = GitGutterGetHunkSummary()
  return printf('+%d ~%d -%d', a, m, r)
endfunction

let g:rg_highlight = 1
let g:LanguageClient_serverCommands = {
    \ 'ruby': ['~/.rbenv/shims/solargraph'],
    \ }


" ctrlP
set runtimepath^=~/.vim/bundle/ctrlp.vim

" RSPEC
let g:test#preserve_screen = 1
let g:test#vim#term_position = "belowright"
let test#ruby#rspec#executable = 'DISABLE_SPRING=true bin/rspec --format documentation --color'
let test#enabled_runners = ["ruby#rspec"]
let test#strategy = "neovim"

" SEARCH
hi Search guibg=peru guifg=wheat
set wildignore+=*.so
set wildignore+=*.o,*.out,*.obj,.git,*.rbc,*.rbo,*.class,.svn,*.gem
set wildignore+=*.gif,*.jpg,*.png,*.log
set wildignore+=*.zip,*.tar.gz,*.tar.bz2,*.rar,*.tar.xz
set wildignore+=*/vendor/gems/*,*/vendor/cache/*,*/.bundle
set wildignore+=*.swp,*~,._*
set wildignore+=.DS_Store

"Bd will behave like bd but preserve the split buffer window
command Bd bp\|bd \#

" When editing a file, always jump to the last known cursor position.
autocmd BufReadPost *
      \ if line("'\"") > 1 && line("'\"") <= line("$") |
      \   exe "normal! g`\"" |
      \ endif

if executable('rg')
  set grepprg=rg\ --color=never\ --vimgrep\ --no-heading\ --smart-case
  let g:ctrlp_user_command = 'rg %s --files --color=never --glob ""'
  let g:ctrlp_use_caching = 0
endif

if executable('fzf')
  set rtp+=/usr/local/opt/fzf
endif

" Keymaps

" Use Cmd+k / Cmd+j to jump between linter failures
nmap <silent> <D-k> <Plug>(ale_previous)
nmap <silent> <D-j> <Plug>(ale_next)

" Use Enter to lint
nnoremap <silent><cr> :nohlsearch<cr>:ALELint<cr>

" Map Ctrl + p to open fuzzy find (FZF)
nnoremap <c-p> :Files<cr>
map <Leader>q :split ~/Documents/notes.md<cr>
" remap test commands
nmap <silent> <leader>t :TestNearest<CR>
nmap <silent> <leader>T :TestFile<CR>

" unhighlight search
map <leader>h :noh<CR>

" Find files using Telescope command-line sugar.
nnoremap <leader>ff <cmd>Telescope find_files<cr>
nnoremap <leader>fg <cmd>Telescope live_grep<cr>
nnoremap <leader>fb <cmd>Telescope buffers<cr>
nnoremap <leader>fh <cmd>Telescope help_tags<cr>

" Linters

let g:ale_linters = {
  \ 'javascript':  ['prettier'],
  \ 'json':        ['jsonlint'],
  \ 'markdown':    ['prettier'],
  \ 'eruby':       ['erblint'],
  \ 'ruby':        ['rubocop'],
  \  'go': 	   ['gopls']
  \ }

let g:ale_fixers = {
  \ 'css':         ['prettier'],
  \ 'javascript':  ['prettier'],
  \ 'markdown':    ['prettier'],
  \ 'ruby':        ['rubocop'],
  \ 'yaml':        ['prettier'],
  \ 'html':        ['prettier'],
  \ '*':           ['remove_trailing_lines', 'trim_whitespace']
  \ }

" Visual

let g:ale_fix_on_save = 1
let g:ale_echo_msg_error_str = 'Error'
let g:ale_echo_msg_format = '%s'
let g:ale_echo_msg_warning_str = 'Warning'
let g:ale_sign_error = '❌'
let g:ale_sign_warning = '⚠️'
let g:ale_statusline_format = ['❌%d', '⚠️ %d', '']
let g:ale_set_loclist = 0
let g:ale_set_quickfix = 0
let g:ale_completion_enabled = 1

" JS
" let b:ale_fixers = ['prettier']
" let g:ale_lint_on_text_changed = 0

" Rubocop

let g:ale_ruby_rubocop_auto_correct_all = 1
let g:ale_ruby_rubocop_executable = "bundle"

inoremap <tab> <c-r>=InsertTabWrapper()<cr>
inoremap <s-tab> <c-n>

" Smart tab autocomplete behavior
function! InsertTabWrapper()
  let col = col('.') - 1
  if !col || getline('.')[col - 1] !~ '\k'
    return "\<tab>"
  else
    return "\<c-p>"
  endif
endfunction

" Ruby
let g:ruby_indent_assignment_style = 'variable'
let g:ruby_indent_block_style = 'do'

" Status
function! LinterStatus() abort
  let l:counts = ale#statusline#Count(bufnr(''))

  let l:all_errors = l:counts.error + l:counts.style_error
  let l:all_non_errors = l:counts.total - l:all_errors

  return l:counts.total == 0 ? '✨ all good ✨' : printf(
        \   '😞 %dW %dE',
        \   all_non_errors,
        \   all_errors
        \)
endfunction

set statusline=
set statusline+=%m
set statusline+=\ %f
set statusline+=\ %q
set statusline+=%=
set statusline+=%y
set statusline+=\ %c,
set statusline+=%l/%L
set statusline+=\ %{LinterStatus()}
set statusline=%{FugitiveStatusline()}
" set statusline+=%{GitStatus()}
set statusline^=%{coc#status()}%{get(b:,'coc_current_function','')}

" faster for saves
nmap <leader>w :w!<cr>

" Fuzzy search
" Use The Silver Searcher https://github.com/ggreer/the_silver_searcher
if executable('ag')
  " Use Ag over Grep
  set grepprg=ag\ --nogroup\ --nocolor

  " Use ag in fzf for listing files. Lightning fast and respects .gitignore
  let $FZF_DEFAULT_COMMAND = 'ag --literal --files-with-matches --nocolor --hidden -g ""'
endif

" NerdTree

map <leader>- :NERDTreeToggle<CR>
map <leader>r :NERDTreeFind<cr>
" highlight where file is in tree
map ] :NERDTreeFind<CR>
let g:NERDTreeWinPos = "left"
let g:NERDTreeWinSize = 40
let g:NERDTreeMinimalMenu=1

" keep open after :bd
nnoremap \d :bp<cr>:bd #<cr>

" If another buffer tries to replace NERDTree, put it in the other window, and bring back NERDTree.
autocmd BufEnter * if bufname('#') =~ 'NERD_tree_\d\+' && bufname('%') !~ 'NERD_tree_\d\+' && winnr('$') > 1 |
    \ let buf=bufnr() | buffer# | execute "normal! \<C-W>w" | execute 'buffer'.buf | endif


" Lightline

let g:lightline = {
      \ 'colorscheme': 'tender',
      \ 'active': {
      \   'left': [ [ 'mode', 'paste' ],
      \             [ 'gitbranch', 'readonly', 'filename', 'modified' ] ]
      \ },
      \ 'component_function': {
      \   'gitbranch': 'FugitiveHead'
      \ },
      \ }

" Fugitive Conflict Resolution
nnoremap <leader>gd :Gvdiff<CR>
nnoremap gdh :diffget //2<CR>
nnoremap gdl :diffget //3<CR>

" Fugitive
map <Leader><Leader>c :Git commit<cr>
map <Leader><Leader>b :Git blame<cr>
map <Leader><Leader>s :Git status<cr>
map <Leader><Leader>w :Git write<cr>
map <Leader><Leader>p :Git push<cr>
map <Leader><Leader>f :Git fetch<cr>
map <Leader><Leader>u :Git up<cr>

" Map \p to promote variable assignment to let in rspec
map <leader>p :call PromoteToLet()<cr>
function! PromoteToLet()
  :normal! dd
  :exec '?^\s*describe\|fdescribe\|fcontext\|context\|RSpec\.describe\>'
  :normal! p
  :.s/\(\w\+\)\s\+=\s\+\(.*\)$/let(:\1) { \2 }/
  :normal ==
endfunction


" COC lsp additional settings
nmap gd <Plug>(coc-definition)
nmap K <Plug>(coc-hover)

" remap to confirm completion
inoremap <expr> <cr> coc#pum#visible() ? coc#pum#confirm() : "\<CR>"
inoremap <silent><expr> <cr> coc#pum#visible() ? coc#_select_confirm() : "\<C-g>u\<CR>"
" Use <c-space> to trigger completion.
if has('nvim')
  inoremap <silent><expr> <c-space> coc#refresh()
else
  inoremap <silent><expr> <c-@> coc#refresh()
endif
