" Leader key
" ----------

" Since `map` and `remap` evaluate `<leader>` definition eagerly (i.e. not in
" a lazy manner), we have to set up leader key as soon as possible.
map <Space> <Leader>


" Bootstrapping
" -------------

" The section below automatically installs a plugin management system (in our
" case `vim-plug`) if it's not present in the system already. This means that
" we can copy this config on a clean machine, load nevim and then simply call
" :PlugInstall and have an almost working configuration. "Almost working"
" means that one still needs to install lsp servers and third-party
" requirements for _some_ of the packages. Since this is very much plugin
" dependentl, at the moment it's not clear how to automate this.
let sitedir = stdpath('data') . '/site'
let vimplug = sitedir . '/autoload/plug.vim'

if empty(glob(vimplug))
silent execute
    \ '!curl -fLo ' . vimplug .
    \ ' --create-dirs  https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim'
autocmd VimEnter * PlugInstall --sync | source $MYVIMRC
endif


" Plugins
" -------

" The section below imports all the plugin needed by the configuration.
let plugdir = stdpath('data') . '/plugged'
call plug#begin(plugdir)

" Make vim-plug manage itself
Plug 'junegunn/vim-plug'

" Some of my favourite color themes
Plug 'folke/tokyonight.nvim'

" Text icons
Plug 'kyazdani42/nvim-web-devicons'

" Fuzzy everything
Plug 'nvim-lua/plenary.nvim'
Plug 'nvim-telescope/telescope.nvim'
Plug 'nvim-telescope/telescope-project.nvim'

" Modern syntax highlight with `tree-sitter`
Plug 'nvim-treesitter/nvim-treesitter', {'do': ':TSUpdate'}

" Code completion backend through LSP servers
Plug 'neovim/nvim-lspconfig'

" Code completion frontend with `coq` (ridiculously fast!)
Plug 'ms-jpq/coq_nvim', {'branch': 'coq'}
Plug 'ms-jpq/coq.artifacts', {'branch': 'artifacts'}

" Automatically set `cwd` to the root of the current project
Plug 'airblade/vim-rooter'

" Use a custom statusline
Plug 'nvim-lualine/lualine.nvim'

" Toggleable terminal
Plug 'akinsho/toggleterm.nvim'

" Commenting
Plug 'numToStr/Comment.nvim'

call plug#end()


" Evaluating
" ----------

" When editing this config we need to re-evaluate parts of it. We define two
" additional commands. The first one evaluates the current line. The second
" one -- the active visual selection.
nnoremap <leader>vs :source %<CR>
vnoremap <leader>vs y:@"<CR>


" Backups
" -------

set nobackup
set nowritebackup
set noswapfile


" Case sensitivity
" ----------------

set ignorecase


" Color scheme
" -------------------

colorscheme tokyonight


" Line numbers and sign column
" ----------------------------

" I'd love to see line numbers only in the programming-related files (but not
" in markdown or LaTeX, for example), but I will be also fine if it's shown
" everywhere. Also, even an empty sign column provides a nice margin to the
" left that I'd like to see all the time as well.
set number
set signcolumn=yes


" Current line
" ------------

" I like to see the current line to be highlighted
set cursorline


" Whitespace
" ----------

" Show whitespace characters
set list

" Automatically expand tabs to 4 spaces. Indent by 4 spaces.
set expandtab
set tabstop=4
set shiftwidth=4

" Automatically remove trailing whitespace when saving the file
autocmd BufWritePre * :%s/\s\+$//e


" Tabs and splits
" ---------------

" `vim` has a quite powerful window system, but the default keybindings make
" you a bit slow when using it. Here are more conventional ones.

" Quick navigation between the tabs
noremap <C-t> :tabnew<CR>
noremap <C-w> :tabclose<CR>

inoremap <C-t> <ESC>:tabnew<CR>
inoremap <C-w> <ESC>:tabclose<CR>

tnoremap <C-t> <C-\><C-n>:tabnew<CR>
tnoremap <C-w> <C-\><C-n>:tabclose<CR>

noremap <A-1> 1gt
noremap <A-2> 2gt
noremap <A-3> 3gt
noremap <A-4> 4gt
noremap <A-5> 5gt
noremap <A-6> 6gt
noremap <A-7> 7gt
noremap <A-8> 8gt
noremap <A-9> 9gt

inoremap <A-1> <ESC>1gt
inoremap <A-2> <ESC>2gt
inoremap <A-3> <ESC>3gt
inoremap <A-4> <ESC>4gt
inoremap <A-5> <ESC>5gt
inoremap <A-6> <ESC>6gt
inoremap <A-7> <ESC>7gt
inoremap <A-8> <ESC>8gt
inoremap <A-9> <ESC>9gt

tnoremap <A-1> <C-\><C-n>1gt
tnoremap <A-2> <C-\><C-n>2gt
tnoremap <A-3> <C-\><C-n>3gt
tnoremap <A-4> <C-\><C-n>4gt
tnoremap <A-5> <C-\><C-n>5gt
tnoremap <A-6> <C-\><C-n>6gt
tnoremap <A-7> <C-\><C-n>7gt
tnoremap <A-8> <C-\><C-n>8gt
tnoremap <A-9> <C-\><C-n>9gt

" Quick navigation between the splits
noremap <A-v> :vsp<CR>
noremap <A-s> :split<CR>
noremap <A-q> :q<CR>

tnoremap <A-v> <C-\><C-n>:vsp<CR>
tnoremap <A-s> <C-\><C-n>:split<CR>
tnoremap <A-q> <C-\><C-n>:q<CR>

noremap <A-h> <C-w>h
noremap <A-j> <C-w>j
noremap <A-k> <C-w>k
noremap <A-l> <C-w>l

tnoremap <A-h> <C-\><C-n><C-w>h
tnoremap <A-j> <C-\><C-n><C-w>j
tnoremap <A-k> <C-\><C-n><C-w>k
tnoremap <A-l> <C-\><C-n><C-w>l


" Telescope
" ---------

lua << EOF
local telescope = require('telescope')
telescope.setup {
    defaults = {
        borderchars = { '─', '│', '─', '│', '┌', '┐', '┘', '└'},
        file_ignore_patterns = {'__pycache__/', '%.pyc'},
        layout_config = {
            height = 0.5,
            width = 80
        },
        layout_strategy = 'vertical',
        prompt_prefix = '  ',
        selection_caret = '  '
    },
    pickers = {
        file_browser = {
            hidden = true
        }
    }
}
telescope.load_extension('project')
EOF

noremap <leader>ff :Telescope find_files<CR>
noremap <leader>fe :Telescope file_browser<CR>
noremap <leader>fp :Telescope project<CR>
noremap <leader>fb :Telescope buffers<CR>


" Terminal
" --------

" Automatically enter insert mode when entering a terminal window.
" Automatically switch to normal on exit.
autocmd BufRead,BufEnter,WinEnter term://* startinsert
autocmd BufLeave term://* stopinsert

" Open terminal in a toggle
lua << EOF
require('toggleterm').setup {
    size = function (term)
        if term.direction == 'horizontal' then
           return vim.o.lines * 0.4
        elseif term.direction == 'vertical' then
            return vim.o.columns * 0.5
        else
            return 25
        end
    end
}
EOF

nnoremap <leader>t  :ToggleTerm<CR>
nnoremap <leader>ts :ToggleTerm direction=horizontal<CR>
nnoremap <leader>tv :ToggleTerm direction=vertical<CR>
nnoremap <leader>tt :ToggleTerm direction=tab<CR>


" Status line
" -----------

" I am using a `lualine` with almost default settings.
lua << EOF
require('lualine').setup {
    options = {
        section_separators = '',
        component_separators = '',
    }
}
EOF


" Tree sitter
" -----------

" The section below configures `tree-sitter` to be used for syntax
" highlighting, selection, indentation and automatic delimiters pairing.
lua << EOF
require('nvim-treesitter.configs').setup {
    ensure_installed = 'maintained',
    highlight = {
        enable = true
    },
    incremental_selection = {
        enable = true,
        keymaps = {
            init_selection = 'gnn',
            node_incremental = 'grn',
            scope_incremental = 'grc',
            node_decremental = 'grm'
        }
    },
    indent = {
        enable = true
    }
}
EOF

set foldmethod=expr
set foldminlines=3
set foldexpr=nvim_treesitter#foldexpr()


" Commenting
" ----------

lua << EOF
require("Comment").setup {}
EOF

" Code completion
" ---------------

" Completion backend is handed by the LSP servers of choice. We configure them
" in the corresponding language section. UI is provided by a brilliant and
" blazing-fast COQ. It does not require any additional setup, except that we
" would like it to start automatically once we open a buffer.
let g:coq_settings = {
\ 'auto_start': 'shut-up',
\ 'display.pum.fast_close': v:false }


" VIM
" ---

" It would be cool if editing this very config was done with the help of an
" LSP server. Thankfully, there is such a server!
lua << EOG
local lsp = require('lspconfig')
local coq = require('coq')

lsp.vimls.setup(coq.lsp_ensure_capabilities())
EOG


" Python
" ------

" I am mostly paid for writing python. Thankfully, with LSP and `tree-sitter`
" being set up not a lot is left to do in terms of configuratoin.
lua << EOF
local lsp = require('lspconfig')
local coq = require('coq')

lsp.pyright.setup(coq.lsp_ensure_capabilities())
EOF


" Random key combinations
" -----------------------

nnoremap <C-l> :noh<CR>zz


" TODOs
" -----

" A short list of things I would like to have set up.

" TODO: LSP function signature
" TODO: Maybe prettier tabs
" TODO: A sane way to deal with buffers
" TODO: Something similar to `selectrum` for opening files. Would be great if
"       there was something for the buffers as well.
