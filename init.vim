" Leader key {{{
" --------------

" Since `map` and `remap` evaluate `<leader>` definition eagerly (i.e. not in
" a lazy manner), we have to set up leader key as soon as possible.
map <Space> <Leader>

" }}}

" Bootstrapping {{{
" -----------------

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

" }}}

" Plugins {{{
" -----------

" The section below imports all the plugin needed by the configuration.
let plugdir = stdpath('data') . '/plugged'
call plug#begin(plugdir)

" Make vim-plug manage itself
Plug 'junegunn/vim-plug'

" Some of my favourite color themes
Plug 'folke/tokyonight.nvim'
Plug 'ioreshnikov/solarized'
Plug 'gruvbox-community/gruvbox'

" Text icons
Plug 'kyazdani42/nvim-web-devicons'

" Fuzzy everything
Plug 'nvim-lua/plenary.nvim'
Plug 'nvim-telescope/telescope.nvim'
Plug 'nvim-telescope/telescope-fzf-native.nvim', { 'do': 'make' }
Plug 'nvim-telescope/telescope-project.nvim'
Plug 'nvim-telescope/telescope-file-browser.nvim'
Plug 'tami5/sqlite.lua'
Plug 'nvim-telescope/telescope-frecency.nvim'

" Modern syntax highlight with `tree-sitter`
Plug 'nvim-treesitter/nvim-treesitter', {'do': ':TSUpdate'}

" Managing Git repos
Plug 'TimUntersberger/neogit'

" Git blame
Plug 'f-person/git-blame.nvim'

" Code completion backend through LSP servers
Plug 'neovim/nvim-lspconfig'

" Code completion frontend with `nvim-cmp`
Plug 'hrsh7th/cmp-nvim-lsp'
Plug 'hrsh7th/cmp-buffer'
Plug 'hrsh7th/cmp-path'
Plug 'hrsh7th/cmp-cmdline'
Plug 'hrsh7th/cmp-emoji'
Plug 'hrsh7th/nvim-cmp'

Plug 'onsails/lspkind-nvim'
Plug 'ray-x/lsp_signature.nvim'

" Snippets
Plug 'rafamadriz/friendly-snippets'
Plug 'L3MON4D3/LuaSnip'
Plug 'saadparwaiz1/cmp_luasnip'

" Interactive debugging through DAP
Plug 'mfussenegger/nvim-dap'

" Use a custom statusline
Plug 'nvim-lualine/lualine.nvim'
Plug 'SmiteshP/nvim-gps'

" Toggleable terminal
Plug 'akinsho/toggleterm.nvim'

" Which key
Plug 'folke/which-key.nvim'

" Commenting
Plug 'tpope/vim-commentary'

" Surround
Plug 'machakann/vim-sandwich'

" Sub-word motion
Plug 'bkad/CamelCaseMotion'

" Auto-pairing
Plug 'windwp/nvim-autopairs'

" TeX
Plug 'lervag/vimtex'

" Unicode symbols entry
Plug 'joom/latex-unicoder.vim'

" LSP errors
Plug 'folke/trouble.nvim'

" TODO marks
Plug 'folke/todo-comments.nvim'

" Indentation guides
Plug 'lukas-reineke/indent-blankline.nvim'

" Indent level autodetection
Plug 'timakro/vim-yadi'

" Automatically change cwd to the root of the project
Plug 'ahmedkhalf/project.nvim'

" Tree viewer
Plug 'MunifTanjim/nui.nvim'
Plug 'nvim-neo-tree/neo-tree.nvim', { 'branch': 'v2.x' }

" Theming
Plug 'rktjmp/lush.nvim'

" REST client
Plug 'NTBBloodbath/rest.nvim'

" Org-mode
Plug 'nvim-orgmode/orgmode'

call plug#end()

" }}}

" Evaluating {{{
" --------------

" When editing this config we need to re-evaluate parts of it. We define two
" additional commands. The first one evaluates the current line. The second
" one -- the active visual selection.
nnoremap <silent> <leader>vs :source %<CR>
vnoremap <silent> <leader>vs y:@"<CR>

" }}}

" Logging {{{
" -----------

" Sometimtes I need to debug things. This is where logging comes handy.
lua << EOF
function log(message)
    local date = os.date()
    local info = debug.getinfo(2, "Sl")
    local line = info.short_src .. ":" .. info.currentline
    local output = string.format("%s %s %s\n", date, line, message)

    local file = io.open("/home/me/nvim.log", "a")
    file:write(output)
    file:close()
end

_G.ioextra = {}  -- io are my initials, not I/O
_G.ioextra.log = log
EOF

" }}}

" Use mouse {{{
" -------------

set mouse=a

" }}}

" Use system clipboard {{{
" ------------------------

set clipboard+=unnamedplus

" }}}

" Scroll {{{
" ----------

" I love when there's a bit of space between the current line and the end of
" the window. 5 lines feels like sweet spot.
set scrolloff=5

" }}}

" Backups {{{
" -----------

" Didn't really have to use the backups once, but always annoyed by seeing the
" files on disk.
set nobackup
set nowritebackup
set noswapfile

" }}}

" Automatic file reload {{{
" -------------------------

" trigger `autoread` when files changes on disk
set autoread
autocmd FocusGained,BufEnter,CursorHold,CursorHoldI *
    \ if mode() != 'c' |
    \ checktime |
    \ endif

" notification after file change
autocmd FileChangedShellPost * echo "File changed on disk. Buffer reloaded."

" }}}

" Case sensitivity {{{
" --------------------

" I don't really care about case sensitivity when searching.
set ignorecase
set smartcase

" }}}

" Line numbers and sign column {{{
" --------------------------------

" For buffers that correspond to a file on disk I'd like to see relative line
" numbers and a sign column. The latter might not have a practical use for
" files not associated with an LSP server, but I like it purely for
" aesthetical reasons.

function EnableSignColumn() abort
    setlocal signcolumn=yes:2
endfunction

function EnableEditingHelpers() abort
    setlocal number
    setlocal relativenumber
    setlocal numberwidth=5
    setlocal colorcolumn=80
    call EnableSignColumn()
endfunction

autocmd BufReadPost,BufWritePost,BufNewFile * call EnableEditingHelpers()
autocmd FileType NeogitCommitMessage call EnableEditingHelpers()
autocmd FileType NeogitStatus call EnableSignColumn()

" }}}

" Current line {{{
" ----------------

" I like to see the current line to be highlighted
set cursorline

" }}}

" Whitespace {{{
" --------------

" Show whitespace characters
set listchars=tab:???\ ,trail:???

" Try to autodect indent level when a file is open
autocmd BufRead * DetectIndent

" Otherwise use filetype specific
filetype plugin indent on

" As a fallback, indent by 4 spaces
set expandtab
set tabstop=4
set shiftwidth=4

" Automatically remove trailing whitespace when saving the file
autocmd BufWritePre * :%s/\s\+$//e

" }}}

" Wrap {{{
" --------

" Break at a "breakeable" character when soft-wrapping lines.
set linebreak
set showbreak=???\ "

" Do not wrap by default. This is overriden in mode-by-mode basis.
set wrap!

" }}}

" Folds {{{
" ---------

" Folds are occasionally useful. I wish I could use tree-sitter aware folds,
" but as of now they're glitchy and tend to randomly collapse when you edit a
" region. Therefore I resort to good old fold by marker.
set foldmethod=marker

" }}}

" Tabs and splits {{{
" -------------------

" `vim` has a quite powerful window system, but the default keybindings make
" you a bit slow when using it. Here are more conventional ones.

" Quick navigation between the tabs
noremap <silent> <C-t> :tabnew<CR>
noremap <silent> <C-w> :tabclose<CR>

inoremap <silent> <C-t> <ESC>:tabnew<CR>
inoremap <silent> <C-w> <ESC>:tabclose<CR>

tnoremap <silent> <C-t> <C-\><C-n>:tabnew<CR>
tnoremap <silent> <C-w> <C-\><C-n>:tabclose<CR>

noremap <silent> <A-1> 1gt
noremap <silent> <A-2> 2gt
noremap <silent> <A-3> 3gt
noremap <silent> <A-4> 4gt
noremap <silent> <A-5> 5gt
noremap <silent> <A-6> 6gt
noremap <silent> <A-7> 7gt
noremap <silent> <A-8> 8gt
noremap <silent> <A-9> 9gt

inoremap <silent> <A-1> <ESC>1gt
inoremap <silent> <A-2> <ESC>2gt
inoremap <silent> <A-3> <ESC>3gt
inoremap <silent> <A-4> <ESC>4gt
inoremap <silent> <A-5> <ESC>5gt
inoremap <silent> <A-6> <ESC>6gt
inoremap <silent> <A-7> <ESC>7gt
inoremap <silent> <A-8> <ESC>8gt
inoremap <silent> <A-9> <ESC>9gt

tnoremap <silent> <A-1> <C-\><C-n>1gt
tnoremap <silent> <A-2> <C-\><C-n>2gt
tnoremap <silent> <A-3> <C-\><C-n>3gt
tnoremap <silent> <A-4> <C-\><C-n>4gt
tnoremap <silent> <A-5> <C-\><C-n>5gt
tnoremap <silent> <A-6> <C-\><C-n>6gt
tnoremap <silent> <A-7> <C-\><C-n>7gt
tnoremap <silent> <A-8> <C-\><C-n>8gt
tnoremap <silent> <A-9> <C-\><C-n>9gt

" Quick navigation between the splits
noremap <silent> <A-v> :vsp<CR>
noremap <silent> <A-s> :split<CR>
noremap <silent> <A-q> :q<CR>
noremap <silent> <A-o> :only<CR>

tnoremap <silent> <A-v> <C-\><C-n>:vsp<CR>
tnoremap <silent> <A-s> <C-\><C-n>:split<CR>
tnoremap <silent> <A-q> <C-\><C-n>:q<CR>
tnoremap <silent> <A-o> <C-\><C-n>:only<CR>

noremap <silent> <A-h> <C-w>h
noremap <silent> <A-j> <C-w>j
noremap <silent> <A-k> <C-w>k
noremap <silent> <A-l> <C-w>l

tnoremap <silent> <A-h> <C-\><C-n><C-w>h
tnoremap <silent> <A-j> <C-\><C-n><C-w>j
tnoremap <silent> <A-k> <C-\><C-n><C-w>k
tnoremap <silent> <A-l> <C-\><C-n><C-w>l

" }}}

" Movement on wrapped lines {{{
" -----------------------------

" I am using soft line-wrap everywhere. The default navigation commands in vim
" work on physical lines, not wrapped ones. This is really inconvinient. This
" should fix it.

nnoremap <silent> <expr> j v:count ? 'j' : !&wrap ? 'j' : 'gj'
nnoremap <silent> <expr> k v:count ? 'k' : !&wrap ? 'k' : 'gk'
nnoremap <silent> <expr> ^ v:count ? '^' : !&wrap ? '^' : 'g^'
nnoremap <silent> <expr> 0 v:count ? '0' : !&wrap ? '0' : 'g0'
nnoremap <silent> <expr> $ v:count ? '$' : !&wrap ? '$' : 'g$'

vnoremap <silent> <expr> j v:count ? 'j' : !&wrap ? 'j' : 'gj'
vnoremap <silent> <expr> k v:count ? 'k' : !&wrap ? 'k' : 'gk'
vnoremap <silent> <expr> ^ v:count ? '^' : !&wrap ? '^' : 'g^'
vnoremap <silent> <expr> 0 v:count ? '0' : !&wrap ? '0' : 'g0'
vnoremap <silent> <expr> $ v:count ? '$' : !&wrap ? '$' : 'g$'

" }}}

" Automatically set cwd {{{
" -------------------------

lua << EOF
require('project_nvim').setup {}
EOF

" }}}

" Telescope {{{
" -------------

lua << EOF
local telescope = require('telescope')
local actions = require('telescope.actions')

telescope.setup {
    defaults = {
        border = true,
        borderchars = { ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' '},
        file_ignore_patterns = {
            '__pycache__/',
            '%.pyc',
            'node_modules/',
            'target/',
            'gen/'
        },
        layout_strategy = 'bottom_pane',
        layout_config = {
            height = 0.55,
            prompt_position = 'top',
        },
        path_display = function (opts, path)
            return ' ' .. path
        end,
        prompt_prefix = '  ???  ',
        prompt_title = false,
        results_title = ' ',
        selection_caret = '  ',
        sorting_strategy = 'ascending'
    },
    extensions = {
        file_browser = {
            dir_icon = '???',
            hidden = true,
        },
        fzf = {
            fuzzy = true,
            override_generic_sorter = true,
            override_file_sorter = true
        },
        project = {
            base_dirs = {
                { '~/Code', max_depth = 2 },
                { '~/.local/share/nvim/plugged', max_depth = 2 }
            }
        }
    },
    pickers = {
        buffers = {
            ignore_current_buffer = true,
            sort_lastused = true,
            mappings = {
                n = {
                    ['d'] = actions.delete_buffer
                },
                i = {
                    ['<C-d>'] = actions.delete_buffer
                },
            }
        }
    }
}

telescope.load_extension('project')
telescope.load_extension('file_browser')
telescope.load_extension('fzf')
telescope.load_extension('frecency')
EOF

noremap <silent> <leader>ff :Telescope find_files<CR>
noremap <silent> <leader>fe :Telescope file_browser<CR>
noremap <silent> <leader>fp :Telescope project<CR>
noremap <silent> <leader>fb :Telescope buffers<CR>
noremap <silent> <leader>b  :Telescope buffers<CR>
noremap <silent> <leader>fg :Telescope live_grep<CR>
noremap <silent> <leader>fG :lua require('telescope.builtin').live_grep({grep_open_files=true})<CR>
noremap <silent> <leader>fl :Telescope lsp_workspace_symbols<CR>
noremap <silent> <leader>fh :Telescope frecency<CR>
noremap <silent> <leader>fm :Telescope marks<CR>
noremap <silent> <leader>fr :Telescope resume<CR>

hi link TelescopeNormal NormalFloat
hi link TelescopeBorder NormalFloat
hi link TelescopePromptPrefix Comment
hi link TelescopeTitle Ignore

" }}}

" Terminal {{{
" ------------

" Automatically enter insert mode when entering a terminal window.
" Automatically switch to normal on exit.
autocmd WinEnter term://* startinsert
autocmd WinLeave term://* stopinsert
" SEE: https://github.com/neovim/neovim/pull/16596

" Open terminal in a toggle
lua << EOF
require('toggleterm').setup {
    highlights = {
        Normal = { link = 'NormalFloat' },
        StatusLine = { link = 'FloatBorder' },
        StatusLineNC = { link = 'FloatBorder' },
    },
    shade_terminals = false,
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

" Setup DevIcons icon for ToggleTerm
lua << EOF
require('nvim-web-devicons').set_icon({
    toggleterm = {
        icon = '???',
        name = 'Terminal'
    }
})
EOF

nnoremap <silent> <leader>ts :ToggleTerm direction=horizontal<CR>
nnoremap <silent> <leader>tv :ToggleTerm direction=vertical<CR>
nnoremap <silent> <leader>tt :ToggleTerm direction=tab<CR>

" }}}

" Which key {{{
" -------------

lua require('which-key').setup()

" }}}

" Command line {{{
" ----------------

" It's possible now to hide command line and it looks neat!
set cmdheight=0

" }}}

" Status line {{{
" ---------------

" I am using a `lualine` with almost default settings.
lua << EOF
local filename = require('lualine.components.filename'):extend()

filename.apply_icon = require('lualine.components.filetype').apply_icon

local modesymbol = {
    ['NORMAL']   = '??? NOR',
    ['INSERT']   = '??? INS',
    ['VISUAL']   = '??? VIS',
    ['V-LINE']   = '??? VIS',
    ['V-BLOCK']  = '??? VIS',
    ['TERMINAL'] = '??? ZSH',
    ['COMMAND']  = '??? CMD',
}

function mode()
    local mode = require('lualine.utils.mode').get_mode()
    local symb = modesymbol[mode]
    if symb == nil then
        return mode
    else
        return symb
    end
end

function signature()
    if not pcall(require, 'lsp_signature') then return end
    local signature = require('lsp_signature').status_line()
    return signature.label
end

local gps = require('nvim-gps')
gps.setup()

require('lualine').setup {
    options = {
        component_separators = '',
        section_separators = '',
        disabled_filetypes = { 'toggleterm' }
    },
    sections = {
        lualine_a = {
            {
                mode,
                padding = { left = 1, right = 1 }
            },
        },
        lualine_b = {
            {
                filename,
                padding = { left = 2, right = 2 }
            },
        },
        lualine_c = {
            'progress',
            'location',
            { gps.get_location, cond = gps.is_available },
            { signature }
        },
        lualine_x = {
            'branch',
            'fileformat',
            'encoding',
        },
        lualine_y = {
            {
                'diff',
                colored = false,
                symbols = {added = '???', modified = '??? ', removed = '???  ' }
            },
            {
                'diagnostics',
                colored = false,
                padding = { left = 2, right = 1 }
            },
        },
        lualine_z = {
            {
                'filetype',
                colored = false,
                padding = { left = 2, right = 1 }
            },
        }
    },
    inactive_sections = {
        lualine_a = {},
        lualine_b = {
            {
                filename,
                padding = { left = 2, right = 2 }
            }
        },
        lualine_c = {},
        lualine_x = {},
        lualine_y = {},
        lualine_z = {}
    }
}
EOF

" }}}

" Indentation guide {{{
" ---------------------

" XXX: The usability is sadly not that great due to a long-standing bug in
" neovim:
"     https://github.com/neovim/neovim/issues/6591

" The setup is minimalistic -- I mostly disable the indentation guides in the
" modes I don't want them to see.
lua << EOF
require('indent_blankline').setup {
    filetype_exclude = {
        'help',
        'markdown',
        'neo-tree',
        'NeogitStatus',
        'TelescopePrompt',
        'tex',
        'toggleterm',
        'Trouble',
    }
}
EOF

" }}}

" Git {{{
" -------

" Almost no setup required
lua << EOF
require('neogit').setup {
    commit_popup = { kind = 'vsplit' },
    disable_commit_confirmation = true,
    disable_hint = true,
    signs = {
        section = {' ???' , ' ???'},
        item = {' ???' , ' ???'},
    }
}
EOF

" A simple key combination for opening git status anywhere
noremap <silent> <leader>g :Neogit<CR>

" Git blame as virtual text
let g:gitblame_enabled = 0
let g:gitblame_highlight_group = 'DiagnosticVirtualTextInfo'
let g:gitblame_message_template = '??? <author> "<summary>" on <date>'
noremap <silent> <leader>gt :GitBlameToggle<CR>

" }}}

" Tree sitter {{{
" ---------------

" The section below configures `tree-sitter` to be used for syntax
" highlighting, selection, indentation and automatic delimiters pairing.
lua << EOF
require('orgmode').setup_ts_grammar()
require('nvim-treesitter.configs').setup {
    ensure_installed = 'all',
    ignore_install = {'phpdoc'},
    highlight = {
        enable = true,
        additional_vim_regex_highlighting = {'org'}
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
        enable = true,
        disable = { 'python' }
    }
}
EOF
" NOTE: about `ignore_install` above: I want to use treesitter for everything,
" but I want to stick to stable grammar files. Until April 2022 it was
" possible to do this with setting `ensure_installed = 'maintained'`. Since
" April 2022 'maintained' was marked as deprecated and I switched to 'all'.
" Some of the grammars in 'all' are occasionally broken. One of them is
" 'phpdoc', but the list will surely grow.

" }}}

" Subword navigation {{{
" ----------------------

" This is a really cool plugin that allow one to navigate based on a subword,
" i.e. it treats 'Camel' and 'Case' in 'CamelCase', 'snake' and 'case' in
" 'snake_case' and 'kebab' and 'case' in 'kebab-case' as separate words.

map <silent> w <Plug>CamelCaseMotion_w
map <silent> b <Plug>CamelCaseMotion_b
map <silent> e <Plug>CamelCaseMotion_e
map <silent> ge <Plug>CamelCaseMotion_ge
sunmap w
sunmap b
sunmap e
sunmap ge

omap <silent> iw <Plug>CamelCaseMotion_iw
xmap <silent> iw <Plug>CamelCaseMotion_iw
omap <silent> ib <Plug>CamelCaseMotion_ib
xmap <silent> ib <Plug>CamelCaseMotion_ib
omap <silent> ie <Plug>CamelCaseMotion_ie
xmap <silent> ie <Plug>CamelCaseMotion_ie

imap <silent> <S-Left> <C-o><Plug>CamelCaseMotion_b
imap <silent> <S-Right> <C-o><Plug>CamelCaseMotion_w

" }}}

" Snippets {{{
" ------------

lua << EOF
require("luasnip.loaders.from_vscode").lazy_load()
EOF

" }}}

" Code completion {{{
" -------------------

" Completion backend is handed by the LSP servers of choice. We configure them
" in the corresponding language section. UI is provided by nvim-cmp.

set pumheight=16
set pumwidth=32
set completeopt=menu,menuone,noselect

lua << EOF

local has_words_before = function()
  local line, col = unpack(vim.api.nvim_win_get_cursor(0))
  return col ~= 0 and vim.api.nvim_buf_get_lines(0, line - 1, line, true)[1]:sub(col, col):match("%s") == nil
end

local cmp = require('cmp')
local luasnip = require('luasnip')

cmp.setup({
    snippet = {
        expand = function(args)
            require('luasnip').lsp_expand(args.body)
        end,
    },
    mapping = cmp.mapping.preset.insert({
        ['<C-b>'] = cmp.mapping.scroll_docs(-4),
        ['<C-f>'] = cmp.mapping.scroll_docs(4),
        ['<C-Space>'] = cmp.mapping.complete(),
        ['<C-e>'] = cmp.mapping.abort(),
        ['<CR>'] = cmp.mapping.confirm(),
        ['<Tab>'] = cmp.mapping(function(fallback)
            if cmp.visible() then
                cmp.select_next_item()
            elseif luasnip.expand_or_jumpable() then
                luasnip.expand_or_jump()
            elseif has_words_before() then
                cmp.complete()
            else
                fallback()
            end
        end, { "i", "s" }),
        ['<S-Tab>'] = cmp.mapping(function(fallback)
            if cmp.visible() then
                cmp.select_prev_item()
            elseif luasnip.jumpable(-1) then
                luasnip.jump(-1)
            else
                fallback()
            end
        end, { "i", "s" }),
    }),
    sources = cmp.config.sources(
        {
            { name = 'nvim_lsp' },
            { name = 'luasnip' },
        },
        {
            { name = 'buffer' },
        },
        {
            { name = 'nvim_lsp_signature_help' }
        },
        {
            { name = 'emoji' }
        },
        {
            { name = 'orgmode' }
        }
    ),
    formatting = {
        format = require('lspkind').cmp_format({
            mode = 'symbol_text',
            menu = ({
                buffer = 'Buffer',
                nvim_lsp = 'LSP',
                luasnip = 'SNIP',
                nvim_lua = 'Lua',
                latex_symbols = 'TeX'
            })
        })
    }
})

require('lsp_signature').setup {
    floating_window = false,
    floating_window_off_x = 0,
    hint_prefix = '??? ',
    handler_opts = {
        border = "none"
    }
}
EOF

" }}}

" Debugging with DAP {{{
" ----------------------

" General settings
lua << EOF
require('dap')

vim.fn.sign_define(
    'DapBreakpoint', {
        text = ' ???',
        texthl = 'DiagnosticError',
        linehl = '',
        numhl = 'DiagnosticError'
    })
vim.fn.sign_define(
    'DapBreakpointCondition', {
        text = ' ???',
        texthl = 'DiagnosticWarning',
        linehl = '',
        numhl = 'DiagnosticWarning'
    })
vim.fn.sign_define(
    'DapBreakpointRejected', {
        text = ' ???',
        texthl = 'Comment',
        linehl = '',
        numhl = 'Comment'
    })
vim.fn.sign_define(
    'DapStopped', {
        text = ' ???',
        texthl = 'DiagnosticHint',
        linehl = '',
        numhl = 'DiagnosticHint'
    })
EOF

" Commands
command! DapClearBreakpoints lua require('dap').clear_breakpoints()<CR>

" Keybindings
nnoremap <silent> <leader>oc :DapContinue<CR>
nnoremap <silent> <leader>ot :DapTerminate<CR>
nnoremap <silent> <leader>ob :DapToggleBreakpoint<CR>
nnoremap <silent> <leader>os :DapStepOver<CR>
nnoremap <silent> <leader>oi :DapStepInto<CR>
nnoremap <silent> <leader>oo :DapStepOut<CR>
nnoremap <silent> <leader>or :DapToggleRepl<CR>
nnoremap <silent> <leader>oq :DapClearBreakpoints<CR>

nnoremap <silent> <F5> :DapContinue<CR>
nnoremap <silent> <F9> :DapToggleBreakpoint<CR>
nnoremap <silent> <F10> :DapStepOver<CR>
nnoremap <silent> <F11> :DapStepInto<CR>

" }}}

" Automatic delimiter pairing {{{
" -------------------------------

lua << EOF
require('nvim-autopairs').setup {}
EOF

" }}}

" General LSP setup {{{
" ---------------------

lua << EOF
local signs = {
    Error = ' ???',
    Warn = ' ???',
    Hint = ' ???',
    Info = ' ???',
}
for type, icon in pairs(signs) do
  local hl = 'DiagnosticSign' .. type
  vim.fn.sign_define(hl, { text = icon, texthl = hl, numhl = 'LineNr' })
end

_G.ioextra.on_attach = function(client, buffer)
    vim.api.nvim_buf_set_keymap(
        buffer,
        'n', 'gD', '<cmd>lua vim.lsp.buf.declaration()<CR>',
        { noremap = true, silent = true })
    vim.api.nvim_buf_set_keymap(
        buffer,
        'n', 'gd', '<cmd>lua vim.lsp.buf.definition()<CR>',
        { noremap = true, silent = true })
    vim.api.nvim_buf_set_keymap(
        buffer,
        'n', 'gtd', '<cmd>lua vim.lsp.buf.type_definition()<CR>',
        { noremap = true, silent = true })
    vim.api.nvim_buf_set_keymap(
        buffer,
        'n', 'gi', '<cmd>lua vim.lsp.buf.implementation()<CR>',
        { noremap = true, silent = true })
    vim.api.nvim_buf_set_keymap(
        buffer,
        'n', 'gr', '<cmd>lua vim.lsp.buf.references()<CR>',
        { noremap = true, silent = true })
    vim.api.nvim_buf_set_keymap(
        buffer,
        'n', 'ca', '<cmd>lua vim.lsp.buf.code_action()<CR>',
        { noremap = true, silent = true })
    vim.api.nvim_buf_set_keymap(
        buffer,
        'n', 'K', '<cmd>lua vim.lsp.buf.hover()<CR>',
        { noremap = true, silent = true })
end
EOF

command! LspGotoDeclaration    lua vim.lsp.buf.declaration()<CR>
command! LspGotoDefinition     lua vim.lsp.buf.definition()<CR>
command! LspHover              lua vim.lsp.buf.hover()<CR>
command! LpsGotoImplementation lua vim.lsp.buf.implentation()<CR>
command! LspSignature          lua vim.lsp.buf.signature_help()<CR>
command! LspRename             lua vim.lsp.buf.rename()<CR>
command! LspCodeAction         lua vim.lsp.buf.code_action()<CR>

" }}}

" Error diagnostics {{{
" ---------------------

lua << EOF
require('trouble').setup {
    indent_lines = false
}
EOF

noremap <silent> <leader>ef :TroubleToggle document_diagnostics<CR>
noremap <silent> <leader>ew :TroubleToggle workspace_diagnostics<CR>

hi link TroubleNormal LspTroubleNormal

" }}}

" TODO comments {{{
" -----------------

" A neat utility for highlighting the comment-keywords.

" NOTE: Before we set it up, it's a good idea to disable a couple of builtin
" highlight groups.

hi clear Todo
hi clear WarningMsg

lua << EOF
require('todo-comments').setup {
    keywords = {
        FIX = {
            icon = ' ???',
            color = 'error',
            alt = { 'FIXME', 'BUG', 'FIXIT', 'ISSUE' },
        },
        TODO = {
            icon = ' ???',
            color = 'info'
        },
        DONE = {
            icon = ' ???',
            color = 'hint'
        },
        HACK = {
            icon = ' ???',
            color = 'warning'
        },
        WARN = {
            icon = ' ???',
            color = 'warning',
            alt = { 'WARNING', 'XXX' }
        },
        PERF = {
            icon = ' ???',
            alt = { 'OPTIM', 'OPTIMIZE', 'PERFORMANCE' }
        },
        NOTE = {
            icon = ' ???',
            color = 'hint',
            alt = { 'INFO' }
        }
    },
    highlight = {
        after = '',
        keyword = 'bg'
    }
}
EOF

noremap <silent> <leader>et :TodoTrouble<CR>

" }}}

" Filesystem tree {{{
" -------------------

lua << EOF
require('neo-tree').setup {
    enable_git_status = false,
    enable_diagnostics = false,
    filesystem = {
        follow_current_file = true,
        use_libuv_file_watcher = true,
        renderers = {
            directory = {
                {
                    'icon',
                    folder_closed = '???',
                    folder_open = '???',
                    padding = '  '
                },
                { 'current_filter' },
                { 'name' }
            },
            file = {
                {
                    'icon',
                    default = '???',
                    padding = '  '
                },
                { 'name' },
            }
        },
        window = {
            position = "left",
            width = function ()
                local suffix = "taxify/server"
                if vim.fn.getcwd():sub(-string.len(suffix)) == suffix then
                    return 80
                else
                    return 50
                end
            end
        },
    },
    window = {
        mappings = {
            ["<space>"] = "none",  -- I like my leader key
            ["<tab>"] = "toggle_node",
            ["/"] = "none",        -- I don't like filters, and I navigate by search
        }
    }
}
EOF

nnoremap <silent> <leader>d :Neotree focus toggle<CR>

" }}}

" Language: VIM {{{
" -----------------

" It would be cool if editing this very config was done with the help of an
" LSP server. Thankfully, there is such a server!
lua << EOF
local config = require('lspconfig')
local cmplsp = require('cmp_nvim_lsp')

config.vimls.setup {
    on_attach = ioextra.on_attach,
    capabilities = cmplsp.update_capabilities(
        vim.lsp.protocol.make_client_capabilities()
    )
}
EOF

" }}}

" Language: LUA {{{
" -----------------

" Some of the editing is done in Lua
lua << EOF
local config = require('lspconfig')
local cmplsp = require('cmp_nvim_lsp')

config.sumneko_lua.setup {
    on_attach = ioextra.on_attach,
    capabilities = cmplsp.update_capabilities(
        vim.lsp.protocol.make_client_capabilities()
    )
}
EOF

" }}}

" Language: Python {{{
" --------------------

" LSP settings
lua << EOF
local config = require('lspconfig')
local cmplsp = require('cmp_nvim_lsp')

config.pyright.setup {
    on_attach = ioextra.on_attach,
    capabilities = cmplsp.update_capabilities(
        vim.lsp.protocol.make_client_capabilities()
    )
}
EOF

" DAP settings
lua << EOF
local dap = require('dap')

dap.adapters.python = {
    type = 'executable',
    command = '/usr/bin/env',
    args = { 'python3', '-m', 'debugpy.adapter' }
}

dap.configurations.python = {
    {
        type = 'python',
        request = 'launch',
        name = 'Launch file',
        program = '${file}'
    }
}
EOF

" }}}

" Language: JavaScript and TypeScript {{{
" ---------------------------------------

" And sometimes I need to write frontend code as well.

" LSP settings
lua << EOF
local config = require('lspconfig')
local cmplsp = require('cmp_nvim_lsp')

config.tsserver.setup {
    on_attach = ioextra.on_attach,
    capabilities = cmplsp.update_capabilities(
        vim.lsp.protocol.make_client_capabilities()
    ),
    root_dir = config.util.root_pattern('.git')
}
EOF

" DAP settings
lua << EOF
local dap = require('dap')

dap.adapters.node2 = {
    type = 'executable',
    command = 'node',
    args = { os.getenv('HOME') .. '/repos/rest/vscode-node-debug2/out/src/nodeDebug.js' }
}

dap.configurations.javascript = {
    {
        name = 'Launch',
        type = 'node2',
        request = 'launch',
        program = '${file}',
        cwd = vim.fn.getcwd(),
        sourceMaps = true,
        protocol = 'inspector',
        console = 'integratedTerminal'
    },
    {
        name = 'Attach to process',
        type = 'node2',
        request = 'attach',
        processId = require('dap.utils').pick_process
    },
}

EOF

" }}}

" Language: Ember.js {{{
" ----------------------

" lua << EOF
" local lsp = require('lspconfig')
" local coq = require('coq')

" lsp.ember.setup{
"     on_attach=ioextra.on_attach,
"     unpack(coq.lsp_ensure_capabilities())
" }
" EOF

" }}}

" Language: HTML and CSS {{{
" --------------------------

" Well, that's obvious
lua << EOF
local config = require('lspconfig')
local cmplsp = require('cmp_nvim_lsp')

config.html.setup {
    on_attach = ioextra.on_attach,
    capabilities = cmplsp.update_capabilities(
        vim.lsp.protocol.make_client_capabilities()
    )
}
config.cssls.setup {
    on_attach = ioextra.on_attach,
    capabilities = cmplsp.update_capabilities(
        vim.lsp.protocol.make_client_capabilities()
    )
}
EOF

" }}}

" Language: TeX {{{
" -----------------

" Occasionally I write LaTeX. It turns out there is an LSP mode for that as
" well.
lua << EOF
local config = require('lspconfig')
local cmplsp = require('cmp_nvim_lsp')

config.texlab.setup {
    on_attach = ioextra.on_attach,
    capabilities = cmplsp.update_capabilities(
        vim.lsp.protocol.make_client_capabilities()
    )
}
EOF

let g:unicoder_no_map=v:true
nnoremap <silent> <C-\> :call unicoder#start(0)<CR>
inoremap <silent> <C-\> <C-o>:call unicoder#start(1)<CR>
vnoremap <silent> <C-\> :<C-u>call unicoder#selection()<CR>

" }}}

" Language: Rust {{{
" ------------------

" I need to learn a system programming language and it's definitely not C/C++
" :)
lua << EOF
local config = require('lspconfig')
local cmplsp = require('cmp_nvim_lsp')

config.rust_analyzer.setup {
    on_attach = ioextra.on_attach,
    capabilities = cmplsp.update_capabilities(
        vim.lsp.protocol.make_client_capabilities()
    )
}
EOF

" }}}

" Language: GO {{{
" ----------------

" Eh, why not
lua << EOF
local config = require('lspconfig')
local cmplsp = require('cmp_nvim_lsp')

config.gopls.setup {
    on_attach = ioextra.on_attach,
    capabilities = cmplsp.update_capabilities(
        vim.lsp.protocol.make_client_capabilities()
    )
}
EOF

" }}}

" Language: PHP {{{
" -----------------

" I am shocked as well :)
lua << EOF
local config = require('lspconfig')
local cmplsp = require('cmp_nvim_lsp')

config.phpactor.setup {
    on_attach = ioextra.on_attach,
    capabilities = cmplsp.update_capabilities(
        vim.lsp.protocol.make_client_capabilities()
    )
}
EOF

" }}}

" REST client {{{
" ---------------

lua require('rest-nvim').setup()

nmap <leader>rr <Plug>RestNvim<CR>

" }}}

" Docker {{{
" ----------

autocmd BufRead,BufNewFile Dockerfile.* set filetype=dockerfile

" }}}

" Org-mode {{{
" --------

lua << EOF
require('orgmode').setup {
    org_default_notes_file = '~/Org/Index.org',
    org_todo_keywords = { 'TODO', 'LIVE', '|', 'DONE', 'FAIL', 'ABRT' },
    org_hide_emphasis_markers = true,
    org_capture_templates = {
        s = {
            description = 'Standup',
            template = '* %(return os.date("%A, %d %B %Y", os.time() + 60 * 60 * 24))\n\n  *Yesterday*\n  - %?\n\n  *Today*\n  - \n',
            target = '~/Org/Index.org',
            headline = 'Standups',
        },
        a = {
            description = 'Code annotation',
            template = '* %? \n\n  %a\n',
            target = '~/Org/Index.org',
            headline = 'Code annotations',
        },
    },
}
EOF

" }}}

" Random things {{{
" -----------------

" A faster way to save files
noremap <silent> <leader>w :w<CR>

" And center the current line on screen (and remove highlight)
nnoremap <silent> <C-l> zz:noh<CR>
inoremap <silent> <C-l> <ESC>zz:noh<CR>a

" Clear message area after a timeout
set updatetime=2000
autocmd CursorHold * echon ''

" Close a buffer
nnoremap <silent> <leader>k :bp \| sp \| bn \| bd<CR>

" Copy publically visible url to the current file
lua << EOF
local function exec(command)
    return io.popen(command):read('*a'):gsub('%s+', '')
end

local function git_current_repo()
    local origin = exec('git config --get remote.origin.url')
    if origin:find('^https://') then
        return origin
    else
        for match in string.gmatch(origin, '%S-:(%S+).git') do
            return match
        end
    end
end

local function git_current_hash()
    return exec('git rev-parse HEAD')
end

local function current_location_url()
    local Path = require('plenary.path')

    local absolute_path = vim.api.nvim_buf_get_name(0)
    local cwd = vim.fn.getcwd()
    local relative_path = Path:new(absolute_path):make_relative()

    local repo = git_current_repo()
    local hash = git_current_hash()

    local cursor = vim.api.nvim_win_get_cursor(0)
    local linenr = cursor[1]


    local url =
        'https://github.com/' .. repo ..
        '/blob/' .. hash .. '/' .. relative_path ..
        '#L' .. linenr
    return url
end

local function current_location_markdown_url(repo)
    local url = current_location_url(repo)
    return '[](' .. url .. ')'
end

function copy_current_location_url(repo)
    local url = current_location_url(repo)
    vim.fn.setreg('*', url)
end

function copy_current_location_markdown_url(repo)
    local url = current_location_markdown_url(repo)
    vim.fn.setreg('*', url)
end
EOF

nnoremap <silent> <leader>lgl :lua copy_current_location_url()<CR>
nnoremap <silent> <leader>lgm :lua copy_current_location_markdown_url()<CR>

" Disable startup message
set shm+=I

" }}}

" Neovide specific GUI settings {{{
" ---------------------------------

let g:neovide_input_macos_alt_is_meta=v:true

let g:neovide_hide_mouse_when_typing = 1
let g:neovide_cursor_animation_length = 0.05
let g:neovide_cursor_vfx_mode = 'railgun'
set guifont=JetBrainsMono\ Nerd\ Font:h14

function Neovide_fullscreen()
if g:neovide_fullscreen == v:false
    let g:neovide_fullscreen=v:true
else
    let g:neovide_fullscreen=v:false
endif
endfunction

nnoremap <silent> <F12> :call Neovide_fullscreen()<CR>
inoremap <silent> <F12> <C-o>:call Neovide_fullscreen()<CR>
vnoremap <silent> <F12> <ESC>:call Neovide_fullscreen()<CR>gv

" }}}

" Debugging highlight {{{
" -----------------------

nnoremap <leader><F10> :echo "hi<" . synIDattr(synID(line("."),col("."),1),"name") . '> trans<'
\ . synIDattr(synID(line("."),col("."),0),"name") . "> lo<"
\ . synIDattr(synIDtrans(synID(line("."),col("."),1)),"name") . ">"<CR>

" }}}

" Color scheme {{{
" ----------------

" Enable GUI colors in terminal
set termguicolors

" The best I've seen so far

" set background=dark
" let g:tokyonight_style="night"
" let g:tokyonight_sidebars=["terminal", "qf"]

" colorscheme tokyonight

" hi link NeotreeNormal NormalSB
" hi link NeotreeNormalNc NormalSB

colorscheme solarized

function ToggleBackground()
    if &background == 'dark'
        set background=light
    else
        set background=dark
    endif
endfunction

nnoremap <silent> <F6> :call ToggleBackground()<CR>
inoremap <silent> <F6> <C-o>:call ToggleBackground()<CR>
vnoremap <silent> <F6> <ESC>:call ToggleBackground()<CR>

" }}}

" TODOs
" -----

" A short list of things I would like to have set up.

" BUG: Neogit log has been broken for a month. Should I do the bugfix?
" TODO: Fix the terminal reopening
" TODO: Fix navigating to a changed file from Neogit's status window
