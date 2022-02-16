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
Plug 'ioreshnikov/solarized'

" Text icons
Plug 'kyazdani42/nvim-web-devicons'

" Fuzzy everything
Plug 'nvim-lua/plenary.nvim'
Plug 'nvim-telescope/telescope.nvim'
Plug 'nvim-telescope/telescope-project.nvim'
Plug 'nvim-telescope/telescope-file-browser.nvim'

" Modern syntax highlight with `tree-sitter`
Plug 'nvim-treesitter/nvim-treesitter', {'do': ':TSUpdate'}

" Managing Git repos
Plug 'TimUntersberger/neogit'

" Code completion backend through LSP servers
Plug 'neovim/nvim-lspconfig'

" Code completion frontend with `coq` (ridiculously fast!)
Plug 'ms-jpq/coq_nvim', {'branch': 'coq'}
Plug 'ms-jpq/coq.artifacts', {'branch': 'artifacts'}

" Better search UI
Plug 'kevinhwang91/nvim-hlslens'

" Use a custom statusline
Plug 'nvim-lualine/lualine.nvim'

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

" Automatically change cwd to the root of the project
Plug 'airblade/vim-rooter'

" Tree viewer
Plug 'MunifTanjim/nui.nvim'
Plug 'nvim-neo-tree/neo-tree.nvim'

" Theming
Plug 'rktjmp/lush.nvim'

" REST client
Plug 'NTBBloodbath/rest.nvim'

call plug#end()


" Evaluating
" ----------

" When editing this config we need to re-evaluate parts of it. We define two
" additional commands. The first one evaluates the current line. The second
" one -- the active visual selection.
nnoremap <silent> <leader>vs :source %<CR>
vnoremap <silent> <leader>vs y:@"<CR>


" Logging
" -------

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


" Use mouse
" ---------

set mouse=a


" Scroll
" ------

" I love when there's a bit of space between the current line and the end of
" the window. 5 lines feels like sweet spot.
set scrolloff=5


" Backups
" -------

" Didn't really have to use the backups once, but always annoyed by seeing the
" files on disk.
set nobackup
set nowritebackup
set noswapfile


" Case sensitivity
" ----------------

" I don't really care about case sensitivity when searching.
set ignorecase


" Color scheme
" -------------------

" Enable GUI colors in terminal
set termguicolors

" The best I've seen so far
" let g:tokyonight_style="storm"
" colorscheme tokyonight

set background=light
colorscheme solarized

" set background=light
" colorscheme solarized


" Line numbers and sign column
" ----------------------------

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
    setlocal colorcolumn=80
    call EnableSignColumn()
endfunction

autocmd BufReadPost * call EnableEditingHelpers()
autocmd BufWritePost * call EnableEditingHelpers()
autocmd FileType NeogitCommitMessage call EnableEditingHelpers()
autocmd FileType NeogitStatus call EnableSignColumn()


" Current line
" ------------

" I like to see the current line to be highlighted
set cursorline


" Whitespace
" ----------

" Show whitespace characters
set listchars=tab:→\ ,trail:⋅


" Automatically expand tabs to 4 spaces. Indent by 4 spaces. Those are default
" settings. They can be easily overriden by editing a specific after/ftplugin
" file.
set expandtab
set tabstop=4
set shiftwidth=4

" Automatically remove trailing whitespace when saving the file
autocmd BufWritePre * :%s/\s\+$//e


" Folds
" -----

" Folds are occasionally useful. I wish I could use tree-sitter aware folds,
" but as of now they're glitchy and tend to randomly collapse when you edit a
" region. Therefore I resort to good old fold by marker.
set foldmethod=marker


" Tabs and splits
" ---------------

" `vim` has a quite powerful window system, but the default keybindings make
" you a bit slow when using it. Here are more conventional ones.

" Quick navigation between the tabs {{{
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
" }}}

" Quick navigation between the splits {{{
noremap <silent> <A-v> :vsp<CR>
noremap <silent> <A-s> :split<CR>
noremap <silent> <A-q> :q<CR>

tnoremap <silent> <A-v> <C-\><C-n>:vsp<CR>
tnoremap <silent> <A-s> <C-\><C-n>:split<CR>
tnoremap <silent> <A-q> <C-\><C-n>:q<CR>

noremap <silent> <A-h> <C-w>h
noremap <silent> <A-j> <C-w>j
noremap <silent> <A-k> <C-w>k
noremap <silent> <A-l> <C-w>l

tnoremap <silent> <A-h> <C-\><C-n><C-w>h
tnoremap <silent> <A-j> <C-\><C-n><C-w>j
tnoremap <silent> <A-k> <C-\><C-n><C-w>k
tnoremap <silent> <A-l> <C-\><C-n><C-w>l
" }}}


" Movement on wrapped lines
" -------------------------

" I am using soft line-wrap everywhere. The default navigation commands in vim
" work on physical lines, not wrapped ones. This is really inconvinient. This
" should fix it.
nnoremap <silent> <expr> j v:count ? 'j' : 'gj'
nnoremap <silent> <expr> k v:count ? 'k' : 'gk'
nnoremap <silent> <expr> ^ v:count ? '^' : 'g^'
nnoremap <silent> <expr> 0 v:count ? '0' : 'g0'
nnoremap <silent> <expr> $ v:count ? '$' : 'g$'


" Telescope
" ---------

lua << EOF
local telescope = require('telescope')

telescope.load_extension('project')
telescope.load_extension('file_browser')

telescope.setup {
   defaults = {
       border = true,
       borderchars = { ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' '},
       file_ignore_patterns = {
           '__pycache__/',
           '%.pyc',
           'target/'
       },
       layout_strategy = 'bottom_pane',
       layout_config = {
           height = 0.55,
           prompt_position = 'top',
       },
       path_display = function (opts, path)
           return ' ' .. path
       end,
       prompt_prefix = '    ',
       prompt_title = false,
       results_title = ' ',
       selection_caret = '  ',
       sorting_strategy = 'ascending'
   },
   extensions = {
       file_browser = {
           dir_icon = '',
           hidden = true,
       },
       project = {
           base_dirs = {
               '/home/me/Code/',
               '/home/me/.local/share/nvim/plugged/'
           }
       }
   },
}
EOF

noremap <silent> <leader>ff :Telescope find_files<CR>
noremap <silent> <leader>fe :Telescope file_browser<CR>
noremap <silent> <leader>fp :Telescope project<CR>
noremap <silent> <leader>fb :Telescope buffers<CR>
noremap <silent> <leader>fg :Telescope live_grep<CR>
noremap <silent> <leader>fl :Telescope lsp_workspace_symbols<CR>

hi link TelescopeNormal NormalFloat
hi link TelescopeBorder FloatBorder
hi link TelescopePromptPrefix Comment
hi link TelescopeTitle Ignore


" Terminal
" --------

" Automatically enter insert mode when entering a terminal window.
" Automatically switch to normal on exit.
autocmd WinEnter term://* startinsert
autocmd WinLeave term://* stopinsert
" SEE: https://github.com/neovim/neovim/pull/16596

" Open terminal in a toggle
lua << EOF
require('toggleterm').setup {
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
        icon = '',
        name = 'Terminal'
    }
})
EOF

nnoremap <silent> <leader>t  :ToggleTerm<CR>
nnoremap <silent> <leader>ts :ToggleTerm direction=horizontal<CR>
nnoremap <silent> <leader>tv :ToggleTerm direction=vertical<CR>
nnoremap <silent> <leader>tt :ToggleTerm direction=tab<CR>


" Which key
" ---------

lua require('which-key').setup()


" Status line
" -----------

" I am using a `lualine` with almost default settings.
lua << EOF
local filename = require('lualine.components.filename'):extend()
local filetype = require('lualine.components.filetype'):extend()

filename.apply_icon = require('lualine.components.filetype').apply_icon
filetype.apply_icon = nil  -- XXX: doesn't work :(

require('lualine').setup {
    options = {
        component_separators = '',
        section_separators = ''
    },
    sections = {
        lualine_a = {
            {
                filename,
                padding = { left = 2, right = 2 }
            }
        },
        lualine_b = {
            'progress',
            'location'
        },
        lualine_c = {},
        lualine_x = {
            'branch',
            'fileformat',
            'encoding',
            filetype,
            {
                'diff',
                symbols = {added = '落', modified = ' ', removed = ' '}
            },
            'diagnostics'
        },
        lualine_y = {},
        lualine_z = {}
    },
    inactive_sections = {
        lualine_a = {},
        lualine_b = {
            {
                filename,
                padding = { left = 2, right = 2 }
            },
            'progress',
            'location'
        },
        lualine_c = {},
        lualine_x = {},
        lualine_y = {},
        lualine_z = {}
    }
}
EOF


" Indentation guide
" -----------------

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


" Git
" ---

" Almost no setup required
lua << EOF
require('neogit').setup {
    commit_popup = { kind = 'vsplit' },
    disable_commit_confirmation = true,
    disable_hint = true,
    signs = {
        section = {' ' , ' '},
        item = {' ' , ' '},
    }
}
EOF

" A simple key combination for opening git status anywhere
noremap <silent> <leader>g :Neogit<CR>


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
        enable = true,
        disable = { 'python' }
    }
}
EOF


" Subword navigation
" ------------------

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


" Code completion
" ---------------

" Completion backend is handed by the LSP servers of choice. We configure them
" in the corresponding language section. UI is provided by a brilliant and
" blazing-fast COQ. It does not require any additional setup, except that we
" would like it to start automatically once we open a buffer.

lua << EOF
vim.g.coq_settings = {
    auto_start = 'shut-up',
    clients = {
        lsp = {
            enabled = true,
            weight_adjust = 1.50
        },
        snippets = {
            enabled = true,
            weight_adjust = 1.25
        },
        tree_sitter = {
            enabled = true,
            weight_adjust = 1.00
        },
        buffers = {
            enabled = false,  -- there's no way I can make it rank below everything
            weight_adjust = -2.00,
        },
    },
    display = {
        pum = {
            fast_close = false
        }
    },
    -- To work-around auto-pairs we're going to setup up keys by hand
    keymap = {
        recommended = false
    }
}
EOF


" Automatic delimiter pairing
" ---------------------------

" We start with disabling backspace and enter bindings, since we need to treat
" in a special way when COQ is active (which is almost always).
"
" More details:
"     https://github.com/ms-jpq/coq_nvim/issues/91 (the issue)
"     https://github.com/windwp/nvim-autopairs (search coq_nvim)
"
lua << EOF
require('nvim-autopairs').setup {
    map_bs = false,
    map_cr = false
}
EOF


lua << EOF
local remap = vim.api.nvim_set_keymap
local pairs = require('nvim-autopairs')

-- Those are standard bindings from COQ. The bindings for enter and backspace
-- we need to customize.
remap(
    'i', '<esc>', [[pumvisible() ? '<c-e><esc>' : '<esc>']],
    { expr = true, noremap = true }
)
remap(
    'i', '<c-c>', [[pumvisible() ? '<c-e><c-c>' : '<c-c>']],
    { expr = true, noremap = true }
)
remap(
    'i', '<tab>', [[pumvisible() ? '<c-n>' : '<tab>']],
    { expr = true, noremap = true }
)
remap(
    'i', '<s-tab>', [[pumvisible() ? '<c-p>' : '<bs>']],
    { expr = true, noremap = true }
)

_G.ioextra.cr = function ()
    if vim.fn.pumvisible() ~= 0 then
        if vim.fn.complete_info({ 'selected' }).selected ~= -1 then
            return pairs.esc('<c-y>')
        else
            return pairs.esc('<c-e>') .. pairs.autopairs_cr()
        end
    else
        return pairs.autopairs_cr()
    end
end

_G.ioextra.bs = function ()
    if vim.fn.pumvisible() ~= 0 and vim.fn.complete_info({ 'mode' }).mode == 'eval' then
        return pairs.esc('<c-e>') .. pairs.autopairs_bs()
    else
        return pairs.autopairs_bs()
    end
end

remap('i', '<cr>', 'v:lua.ioextra.cr()', { expr = true, noremap = true })
remap('i', '<bs>', 'v:lua.ioextra.bs()', { expr = true, noremap = true })
EOF


" General LSP setup
" -----------------

lua << EOF
local signs = {
    Error = ' ',
    Warn = ' ',
    Hint = ' ',
    Info = ' ',
}
for type, icon in pairs(signs) do
  local hl = 'DiagnosticSign' .. type
  vim.fn.sign_define(hl, { text = icon, texthl = hl, numhl = hl })
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
end
EOF

command! LspGotoDeclaration    lua vim.lsp.buf.declaration()<CR>
command! LspGotoDefinition     lua vim.lsp.buf.definition()<CR>
command! LspHover              lua vim.lsp.buf.hover()<CR>
command! LpsGotoImplementation lua vim.lsp.buf.implentation()<CR>
command! LspSignature          lua vim.lsp.buf.signature_help()<CR>
command! LspRename             lua vim.lsp.buf.rename()<CR>
command! LspCodeAction         lua vim.lsp.buf.code_action()<CR>


" Error diagnostics
" -----------------

lua << EOF
require('trouble').setup {
    indent_lines = false
}
EOF

noremap <silent> <leader>e  :TroubleToggle document_diagnostics<CR>
noremap <silent> <leader>ef :TroubleToggle document_diagnostics<CR>
noremap <silent> <leader>ew :TroubleToggle workspace_diagnostics<CR>

hi link TroubleNormal LspTroubleNormal


" TODO comments
" -------------

" A neat utility for highlighting the comment-keywords.
lua << EOF
require('todo-comments').setup {
    keywords = {
        FIX = {
            icon = ' ',
            color = 'error',
            alt = { 'FIXME', 'BUG', 'FIXIT', 'ISSUE' },
        },
        TODO = {
            icon = ' ',
            color = 'info'
        },
        HACK = {
            icon = ' ',
            color = 'warning'
        },
        WARN = {
            icon = ' ',
            color = 'warning',
            alt = { 'WARNING', 'XXX' }
        },
        PERF = {
            icon = ' ',
            alt = { 'OPTIM', 'OPTIMIZE', 'PERFORMANCE' }
        },
        NOTE = {
            icon = ' ',
            color = 'hint',
            alt = { 'INFO' }
        }
    }
}
EOF

noremap <silent> <leader>et :TodoTrouble<CR>


" Filesystem tree
" ---------------
"
lua << EOF
require('neo-tree').setup {
    filesystem = {
        before_render = function () return end,
        follow_current_file = true,
        use_libuv_file_watcher = true,
        renderers = {
            directory = {
                {
                    'icon',
                    folder_closed = '',
                    folder_open = 'ﱮ',
                    padding = '  '
                },
                { 'current_filter' },
                { 'name' }
            },
            file = {
                {
                    'icon',
                    default = '',
                    padding = '  '
                },
                { 'name' },
            }
        }
    }
}
EOF

nnoremap <silent> <leader>d :NeoTreeShowToggle<CR>


" VIM
" ---

" It would be cool if editing this very config was done with the help of an
" LSP server. Thankfully, there is such a server!
lua << EOF
local lsp = require('lspconfig')
local coq = require('coq')

lsp.vimls.setup(coq.lsp_ensure_capabilities())
EOF


" LUA
" ---

" Some of the editing is done in Lua
lua << EOF
local lsp = require('lspconfig')
local coq = require('coq')

lsp.sumneko_lua.setup(coq.lsp_ensure_capabilities())
EOF


" Python
" ------

" I am mostly paid for writing python. Thankfully, with LSP and `tree-sitter`
" being set up not a lot is left to do in terms of configuratoin.
lua << EOF
local lsp = require('lspconfig')
local coq = require('coq')

lsp.pyright.setup{
    on_attach=ioextra.on_attach,
    unpack(coq.lsp_ensure_capabilities())
}
EOF


" JavaScript and TypeScript
" -------------------------

" And sometimes I need to write frontend code as well.
lua << EOF
local lsp = require('lspconfig')
local coq = require('coq')

lsp.tsserver.setup{
    on_attach=ioextra.on_attach,
    unpack(coq.lsp_ensure_capabilities())
}
EOF


" HTML and CSS
" ------------

" Well, that's obvious
lua << EOF
local lsp = require('lspconfig')
local coq = require('coq')

lsp.html.setup{
    on_attach=ioextra.on_attach,
    unpack(coq.lsp_ensure_capabilities())
}
lsp.cssls.setup{
    on_attach=ioextra.on_attach,
    unpack(coq.lsp_ensure_capabilities())
}
EOF


" TeX
" ---

" Occasionally I write LaTeX. It turns out there is an LSP mode for that as
" well.
lua << EOF
local lsp = require('lspconfig')
local coq = require('coq')

lsp.texlab.setup{
    on_attach=ioextra.on_attach,
    unpack(coq.lsp_ensure_capabilities())
}
EOF

let g:unicoder_no_map=v:true
nnoremap <silent> <C-\> :call unicoder#start(0)<CR>
inoremap <silent> <C-\> <Esc>:call unicoder#start(1)<CR>
vnoremap <silent> <C-\> :<C-u>call unicoder#selection()<CR>


" Rust
" ----

" I need to learn a system programming language and it's definitely not C/C++
" :)
lua << EOF
local lsp = require('lspconfig')
local coq = require('coq')

lsp.rust_analyzer.setup{
    on_attach=ioextra.on_attach,
    unpack(coq.lsp_ensure_capabilities())
}
EOF


" GO
" --

" Eh, why not
lua << EOF
local lsp = require('lspconfig')
local coq = require('coq')

lsp.gopls.setup{
    on_attach=ioextra.on_attach,
    unpack(coq.lsp_ensure_capabilities())
}
EOF


" REST client
" -----------

lua require('rest-nvim').setup()

nmap <leader>rr <Plug>RestNvim<CR>


" Random things
" -------------

" A faster way to save files
noremap <silent> <leader>w :w<CR>

" Remove search highlight and center the current line on screen.
nnoremap <silent> <C-l> :noh<CR>zz
inoremap <silent> <C-l> <ESC>:noh<CR>zza

" Clear message area after a timeout
set updatetime=2000
autocmd CursorHold * echon ''


" Neovide specific GUI settings
" -----------------------------

let g:neovide_hide_mouse_when_typing = 1
let g:neovide_cursor_animation_length = 0.03
set guifont=JetBrainsMono\ Nerd\ Font:h13

function Neovide_fullscreen()
if g:neovide_fullscreen == v:false
    let g:neovide_fullscreen=v:true
else
    let g:neovide_fullscreen=v:false
endif
endfunction

map <silent> <F11> :call Neovide_fullscreen()<CR>


" Debugging highlight
" -------------------

nnoremap <F10> :echo "hi<" . synIDattr(synID(line("."),col("."),1),"name") . '> trans<'
\ . synIDattr(synID(line("."),col("."),0),"name") . "> lo<"
\ . synIDattr(synIDtrans(synID(line("."),col("."),1)),"name") . ">"<CR>


" TODOs
" -----

" A short list of things I would like to have set up.

" TODO: LSP function signature
" BUG: Neogit log has been broken for a month. Should I do the bugfix?
