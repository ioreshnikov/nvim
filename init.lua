-- Leader key {{{
-- --------------
-- Since `map` and `remap` evaluate `<leader>` definition eagerly (i.e. not in
-- a lazy manner), we have to set up leader key as soon as possible.
vim.g.mapleader = ' ';
-- }}}

-- Plugins {{{
-- -----------
-- Bootstrap lazy.nvim
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not (vim.uv or vim.loop).fs_stat(lazypath) then
    local lazyrepo = "https://github.com/folke/lazy.nvim.git"
    local out = vim.fn.system({ "git", "clone", "--filter=blob:none", "--branch=stable", lazyrepo, lazypath })
    if vim.v.shell_error ~= 0 then
        vim.api.nvim_echo({
            { "Failed to clone lazy.nvim:\n", "ErrorMsg" },
            { out, "WarningMsg" },
            { "\nPress any key to exit..." },
        }, true, {})
        vim.fn.getchar()
        os.exit(1)
    end
end
vim.opt.rtp:prepend(lazypath)

require('lazy').setup({
    -- Text icons
    'kyazdani42/nvim-web-devicons',

    -- Fuzzy everything
    'nvim-lua/plenary.nvim',
    'nvim-telescope/telescope.nvim',
    { 'nvim-telescope/telescope-fzf-native.nvim', build = 'make' },
    'nvim-telescope/telescope-project.nvim',
    'tami5/sqlite.lua',

    -- Modern syntax highlight with `tree-sitter`
    { 'nvim-treesitter/nvim-treesitter', lazy = false, build = ':TSUpdate' },
    'nvim-treesitter/playground',

    -- Text objects with treesitter
    'nvim-treesitter/nvim-treesitter-textobjects',

    -- Structural searhc and replace
    'cshuaimin/ssr.nvim',

    -- Git blame
    'FabijanZulj/blame.nvim',

    -- Code completion frontend with `blink.cmp`
    {
      "saghen/blink.cmp",
      version = "v1.*"
    },

    -- Debugger
    'mfussenegger/nvim-dap',

    -- Use a custom statusline
    'nvim-lualine/lualine.nvim',

    -- Which key
    'folke/which-key.nvim',

    -- Commenting
    'tpope/vim-commentary',

    -- Surround
    'machakann/vim-sandwich',

    -- Sub-word motion
    'bkad/CamelCaseMotion',

    -- Case coercion
    'tpope/vim-abolish',

    -- Auto-pairing
    'windwp/nvim-autopairs',

    -- TeX
    'lervag/vimtex',

    -- Prettier javascript
    { 'prettier/vim-prettier', build = 'yarn install --frozen-lockfile --production' },

    -- Unicode symbols entry
    'joom/latex-unicoder.vim',

    -- LSP errors
    "https://git.sr.ht/~whynothugo/lsp_lines.nvim",
    'yorickpeterse/nvim-pqf',

    -- Indentation guides
    'lukas-reineke/indent-blankline.nvim',

    -- Indent level autodetection
    'timakro/vim-yadi',

    -- Automatically change cwd to the root of the project
    'ahmedkhalf/project.nvim',

    -- Tree viewer
    'MunifTanjim/nui.nvim',
    {'nvim-neo-tree/neo-tree.nvim', version = "3.38.0"},

    -- REST client
    'NTBBloodbath/rest.nvim',

    -- Database client
    'tpope/vim-dadbod',
    'kristijanhusak/vim-dadbod-ui',
    'kristijanhusak/vim-dadbod-completion',

    -- Live preview commands
    'smjonas/live-command.nvim',

    -- Theming
    'rktjmp/lush.nvim',
    'echasnovski/mini.colors',

    'ioreshnikov/helix',
    { dir = '~/Code/solarized.nvim/' },
    'folke/tokyonight.nvim',

    -- Writing mode
    'folke/zen-mode.nvim',
})
-- }}}

-- Shortcuts {{{
-- -------------
local function concat(...)
    local result = {}
    for _, table in ipairs({...}) do
        for key, value in pairs(table) do
            result[key] = value
        end
    end
    return result
end

local function noremap(opts)
    assert(opts.lhs ~= nil)
    assert(opts.rhs ~= nil)

    return vim.keymap.set(
        opts.mode or '', opts.lhs, opts.rhs, {
            silent = true,
            noremap = true,
            desc = opts.desc
        }
    )
end

local function nnoremap(opts)
    return noremap(concat({mode = 'n'}, opts))
end

local function inoremap(opts)
    return noremap(concat({mode = 'i'}, opts))
end

local function vnoremap(opts)
    return noremap(concat({mode = 'v'}, opts))
end

local function tnoremap(opts)
    return noremap(concat({mode = 't'}, opts))
end
-- }}}

-- Evaluating {{{
-- --------------
-- When editing this config we need to re-evaluate parts of it. We define two
-- additional commands. The first one evaluates the current line. The second
-- one -- the active visual selection.
nnoremap { lhs = '<leader>vs', rhs = ':source %<CR>', desc = 'Evaluate buffer' }
vnoremap { lhs = '<leader>vs', rhs = 'y:@"<CR>', desc = 'Evaluate selection' }
-- }}}

-- Use mouse {{{
-- -------------
vim.opt.mouse = 'a'
-- }}}

-- Use system clipboard {{{
-- ------------------------
vim.opt.clipboard = 'unnamedplus'
-- }}}

-- Scroll {{{
-- ----------
-- I love when there's a bit of space between the current line and the end of
-- the window. 5 lines feels like sweet spot.
vim.opt.scrolloff=5
-- }}}

-- Backups {{{
-- -----------
-- Didn't really have to use the backups once, but always annoyed by seeing the
-- files on disk.
vim.opt.backup = false
vim.opt.writebackup = false
vim.opt.swapfile = false
-- }}}

-- Automatic file reload {{{
-- -------------------------
-- trigger `autoread` when files changes on disk
vim.opt.autoread = true
vim.api.nvim_command([[
    autocmd FocusGained,BufEnter,CursorHold,CursorHoldI *
        \ if mode() != 'c' |
        \ checktime |
        \ endif
]])
-- notification after file change
vim.api.nvim_command([[
    autocmd FileChangedShellPost * echo "File changed on disk. Buffer reloaded."
]])
-- }}}

-- Case sensitivity {{{
-- --------------------
-- I don't really care about case sensitivity when searching.
vim.opt.ignorecase = true
vim.opt.smartcase = true
-- }}}

-- Line numbers and sign column {{{
-- --------------------------------
-- For buffers that correspond to a file on disk I'd like to see relative line
-- numbers and a sign column. The latter might not have a practical use for
-- files not associated with an LSP server, but I like it purely for
-- aesthetic reasons.
vim.api.nvim_command([[
    function EnableSignColumn() abort
        setlocal signcolumn=yes:2
    endfunction

    function EnableLineNumbers() abort
        setlocal number
        setlocal relativenumber
    endfunction

    function EnableEditingHelpers() abort
        setlocal numberwidth=5
        setlocal colorcolumn=80
        call EnableLineNumbers()
        call EnableSignColumn()
    endfunction

    autocmd BufReadPost,BufNewFile * call EnableEditingHelpers()
]])
-- " }}}

-- Current line {{{
-- ----------------
-- I like to see the current line to be highlighted
vim.opt.cursorline = true
-- }}}

-- Whitespace {{{
-- --------------
-- Show whitespace characters
vim.opt.listchars.extend = 'tab:→ ,trail:⋅'

-- Try to autodect indent level when a file is open
vim.api.nvim_command([[autocmd BufRead * DetectIndent]])

-- Otherwise use filetype specific
-- filetype plugin indent on

-- As a fallback, indent by 4 spaces
vim.opt.expandtab = true
vim.opt.tabstop = 4
vim.opt.shiftwidth = 4

-- Automatically remove trailing whitespace when saving the file
vim.api.nvim_command([[autocmd BufWritePre * :%s/\s\+$//e]])
-- }}}

-- Wrap {{{
-- --------
-- Break at a "breakeable" character when soft-wrapping lines.
vim.opt.linebreak = true
vim.opt.textwidth = 0
vim.opt.wrapmargin = 0
vim.opt.showbreak='⤷ '

-- By default we do not wrap, but that can be overriden in some buffers
vim.opt.wrap = false
vim.opt.linebreak = true
-- }}}

-- Folds {{{
-- ---------
-- Folds are occasionally useful. I wish I could use tree-sitter aware folds,
-- but as of now they're glitchy and tend to randomly collapse when you edit a
-- region. Therefore I resort to good old fold by marker.

vim.opt.foldmethod = 'expr'
vim.opt.foldexpr = "v:lua.vim.treesitter.foldexpr()"
vim.opt.foldtext = ""
vim.opt.foldlevel = 99
-- }}}

-- Movement in tabs and splits {{{
-- -------------------------------
-- `vim` has a quite powerful window system, but the default keybindings make
-- you a bit slow when using it. Here are more conventional ones.

-- Quick navigation between the tabs
noremap { lhs = '<C-t>', rhs = ':tabnew<CR>' }
noremap { lhs = '<C-w>', rhs = ':tabclose<CR>'}
tnoremap { lhs = '<C-t>', rhs = '<C-\\><C-n>:tabnew<CR>' }
tnoremap { lhs = '<C-w>', rhs = '<C-\\><C-n>:tabclose<CR>' }

noremap { lhs = '<A-1>', rhs = '1gt' }
noremap { lhs = '<A-2>', rhs = '2gt' }
noremap { lhs = '<A-3>', rhs = '3gt' }
noremap { lhs = '<A-4>', rhs = '4gt' }
noremap { lhs = '<A-5>', rhs = '5gt' }
noremap { lhs = '<A-6>', rhs = '6gt' }
noremap { lhs = '<A-7>', rhs = '7gt' }
noremap { lhs = '<A-8>', rhs = '8gt' }
noremap { lhs = '<A-9>', rhs = '9gt' }

tnoremap { lhs = '<A-1>', rhs = '<C-\\><C-n>1gt' }
tnoremap { lhs = '<A-2>', rhs = '<C-\\><C-n>2gt' }
tnoremap { lhs = '<A-3>', rhs = '<C-\\><C-n>3gt' }
tnoremap { lhs = '<A-4>', rhs = '<C-\\><C-n>4gt' }
tnoremap { lhs = '<A-5>', rhs = '<C-\\><C-n>5gt' }
tnoremap { lhs = '<A-6>', rhs = '<C-\\><C-n>6gt' }
tnoremap { lhs = '<A-7>', rhs = '<C-\\><C-n>7gt' }
tnoremap { lhs = '<A-8>', rhs = '<C-\\><C-n>8gt' }
tnoremap { lhs = '<A-9>', rhs = '<C-\\><C-n>9gt' }

-- " Quick navigation between the splits
noremap { lhs = '<A-v>', rhs = ':vsp<CR>' }
noremap { lhs = '<A-s>', rhs = ':split<CR>' }
noremap { lhs = '<A-q>', rhs = ':close<CR>' }
noremap { lhs = '<A-o>', rhs = ':only<CR>' }

tnoremap { lhs = '<A-v>', rhs = '<C-\\><C-n>:vsp<CR>' }
tnoremap { lhs = '<A-s>', rhs = '<C-\\><C-n>:split<CR>' }
tnoremap { lhs = '<A-q>', rhs = '<C-\\><C-n>:close<CR>' }
tnoremap { lhs = '<A-o>', rhs = '<C-\\><C-n>:only<CR>' }

noremap { lhs = '<A-h>', rhs = '<C-w>h' }
noremap { lhs = '<A-j>', rhs = '<C-w>j' }
noremap { lhs = '<A-k>', rhs = '<C-w>k' }
noremap { lhs = '<A-l>', rhs = '<C-w>l' }

tnoremap { lhs = '<A-h>', rhs = '<C-\\><C-n><C-w>h' }
tnoremap { lhs = '<A-j>', rhs = '<C-\\><C-n><C-w>j' }
tnoremap { lhs = '<A-k>', rhs = '<C-\\><C-n><C-w>k' }
tnoremap { lhs = '<A-l>', rhs = '<C-\\><C-n><C-w>l' }
-- }}}

-- Movement on wrapped lines {{{
-- -----------------------------
-- I am using soft line-wrap everywhere. The default navigation commands in vim
-- work on physical lines, not wrapped ones. This is really inconvenient. This
-- should fix it.
vim.api.nvim_command([[
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
]])
-- }}}

-- Automatically set cwd {{{
-- -------------------------
do
    local defaults = require('project_nvim.config').defaults
    require('project_nvim').setup {
        detection_methods = { "pattern" },
        patterns = {
            'tsconfig.json',
            'main/',
            unpack(defaults.patterns)
        },
        scope_chdir = 'tab'
    }
end
-- }}}

-- Telescope {{{
-- -------------
local telescope = require('telescope')
local actions = require('telescope.actions')
local sorters = require('telescope.sorters')

telescope.setup {
    defaults = {
        border = true,
        file_ignore_patterns = {
            '__pycache__/',
            '%.pyc',
            'node_modules/',
            'target/',
            'gen/'
        },
        layout_strategy = 'bottom_pane',
        layout_config = {
            height = 0.5,
            prompt_position = 'top',
        },
        prompt_prefix = '   ',
        prompt_title = true,
        sorter = sorters.get_fzy_sorter,
        sorting_strategy = 'ascending',
        winblend = 5,
    },
    extensions = {
        fzf = {
            fuzzy = true,
            override_generic_sorter = true,
            override_file_sorter = true
        },
        project = {
            base_dirs = {
                { '~/Code/', max_depth = 3 },
                { vim.fn.stdpath('data') .. '/lazy', max_depth = 2 },
                { '~/.config/nvim' }
            },
            make_display = function (project)
                local displayer = require("telecope.pickers.entry_display").create {
                    separator = " ",
                    items = {
                        { width = 1},
                        { width = 64 },
                        { width = 0 }
                    }
                }

                return displayer {
                    { " " },
                    { project.title },
                    { project.display_path }
                }
            end
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
telescope.load_extension('fzf')

noremap {
    lhs = '<leader>ff',
    rhs = require('telescope.builtin').find_files,
    desc = 'Files'
}
noremap {
    lhs = '<leader>fb',
    rhs = function ()
        require('telescope.builtin').buffers({ show_all_buffers = true })
    end,
    desc = 'Buffers'
}
noremap {
    lhs = '<leader>b',
    rhs = require('telescope.builtin').buffers,
    desc = 'Buffers'
}
noremap {
    lhs = '<leader>fg',
    rhs = require('telescope.builtin').live_grep,
    desc = 'Grep'
}
noremap {
    lhs = '<leader>fG',
    rhs = function ()
        return require('telescope.builtin').live_grep({ grep_open_files = true })
    end,
    desc = 'Grep open files'
}
noremap {
    lhs = '<leader>fh',
    rhs = require('telescope.builtin').oldfiles,
    desc = 'History'
}
noremap {
    lhs = '<leader>fm',
    rhs = require('telescope.builtin').marks,
    desc = 'Marks'
}
noremap {
    lhs = '<leader>fp',
    rhs = require('telescope').extensions.project.project,
    desc = 'Project'
}
noremap {
    lhs = '<leader>fr',
    rhs = require('telescope.builtin').resume,
    desc = 'Resume'
}

vim.api.nvim_command([[hi link TelescopeNormal NormalFloat]])
vim.api.nvim_command([[hi link TelescopeBorder NormalFloat]])
vim.api.nvim_command([[hi link TelescopePromptPrefix Comment]])
vim.api.nvim_command([[hi link TelescopeTitle Ignore]])
-- }}}

-- Which key {{{
-- -------------
do
    local wk = require('which-key')

    wk.setup({
        preset = "classic",
        delay = 1000,
        icons = {
            mappings = false,
            colors = false,
            breadcrumbs = ">",
            separator = "->",
            group = ""
        },
        layout = {
            spacing = 10
        },
        win = {
            border = "rounded",
            wo = {
                winblend = 5
            }
        }
    })

    wk.add({
        { "<leader>e", group = "Diagnostics/" },
        { "<leader>f", group = "Telescope/" },
        { "<leader>fs", group = "Bolt/" },
        { "<leader>l", group = "Link/" },
        { "<leader>r", group = "REST/" },
        { "<leader>s", group = "Swap/" },
        { "<leader>t", group = "Terminal/" },
        { "<leader>v", group = "Evaluate/" },
        { "<leader>db", group = "Database/" },
    })
end
-- }}}

-- Command line {{{
-- ----------------
-- -- It's possible now to hide command line and it looks neat!
vim.opt.cmdheight = 0

-- -- Except that it doesn't show you when you're recording a macro
vim.api.nvim_command([[autocmd CmdlineEnter * set cmdheight=1]])
vim.api.nvim_command([[autocmd CmdlineLeave * set cmdheight=0]])
vim.api.nvim_command([[autocmd RecordingEnter * set cmdheight=1]])
vim.api.nvim_command([[autocmd RecordingLeave * set cmdheight=0]])
-- }}}

-- Status line {{{
-- ---------------
do
    local filename = require('lualine.components.filename'):extend()

    filename.apply_icon = require('lualine.components.filetype').apply_icon

    local modesymbol = {
        ['NORMAL']   = ' NOR',
        ['INSERT']   = '󰇘 INS',
        ['VISUAL']   = '󰝕 VIS',
        ['V-LINE']   = '󰉸 VIS',
        ['V-BLOCK']  = '󰉶 VIS',
        ['TERMINAL'] = ' ZSH',
        ['COMMAND']  = ' CMD',
    }

    local function mode()
        local mode = require('lualine.utils.mode').get_mode()
        local symb = modesymbol[mode]
        if symb == nil then
            return mode
        else
            return symb
        end
    end

    require('lualine').setup {
        options = {
            component_separators = '',
            section_separators = '',
            disabled_filetypes = {},
            globalstatus = false
        },
        sections = {
            lualine_a = {
                {
                    mode,
                    padding = { left = 2, right = 2 }
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
            },
            lualine_x = {
                'branch',
                'fileformat',
                'encoding',
            },
            lualine_y = {
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
                    padding = { left = 2, right = 2 }
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
end
-- }}}

-- Indentation guide {{{
-- ---------------------
-- XXX: The usability is sadly not that great due to a long-standing bug in
-- neovim:
--     https://github.com/neovim/neovim/issues/6591
-- The setup is minimalistic -- I mostly disable the indentation guides in the
-- modes I don't want them to see.
require('ibl').setup {
    exclude = {
        filetypes = {
            'help',
            'markdown',
            'neo-tree',
            'TelescopePrompt',
            'tex',
            'toggleterm',
        }
    },
    scope = {
        enabled = false
    }
}
-- }}}

require('blame').setup({})

-- Tree sitter {{{
-- ---------------

-- The section below configures `tree-sitter` to be used for syntax
-- highlighting, selection, indentation and automatic delimiters pairing.
require('nvim-treesitter.configs').setup {
    ensure_installed = 'all',
    ignore_install = {'phpdoc', 'ipkg'},
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
    },
    textobjects = {
        select = {
            enable = true,
            lookahead = true,
            keymaps = {
                ["ia"] = "@parameter.inner",
                ["aa"] = "@parameter.outer",
                ["if"] = "@function.inner",
                ["af"] = "@function.outer",
                ["ic"] = "@class.inner",
                ["ac"] = "@class.outer",
            },
        },
        swap = {
            enable = true,
            swap_next = {
                ["<leader>sa"] = "@parameter.inner"
            },
            swap_previous = {
                ["<leader>sA"] = "@parameter.inner"
            }
        },
        move = {
            enable = true,
            set_jumps = true,
            goto_next_start = {
                ["]a"] = "@parameter.inner",
                ["]f"] = "@function.outer",
                ["]c"] = "@class.outer",
            },
            goto_next_end = {
                ["]A"] = "@parameter.outer",
                ["]F"] = "@function.outer",
                ["]C"] = "@class.outer",
            },
            goto_previous_start = {
                ["[a"] = "@parameter.inner",
                ["[f"] = "@function.outer",
                ["[c"] = "@class.outer",
            },
            goto_previous_end = {
                ["[A"] = "@parameter.outer",
                ["[F"] = "@function.outer",
                ["[C"] = "@class.outer",
            }
        }
    },
    playground = {
        enable = true
    }
}
-- NOTE: about `ignore_install` above: I want to use treesitter for everything,
-- but I want to stick to stable grammar files. Until April 2022 it was
-- possible to do this with setting `ensure_installed = 'maintained'`. Since
-- April 2022 'maintained' was marked as deprecated and I switched to 'all'.
-- Some of the grammars in 'all' are occasionally broken. One of them is
-- 'phpdoc', but the list will surely grow.
-- }}}

-- Structural search and replace {{{
-- -----------------------------
noremap { mode = {'n', 'v'}, lhs = '<leader>ssr', rhs = require('ssr').open }
-- }}}

-- Subword navigation {{{
-- ----------------------
-- This is a really cool plugin that allow one to navigate based on a subword,
-- i.e. it treats 'Camel' and 'Case' in 'CamelCase', 'snake' and 'case' in
-- 'snake_case' and 'kebab' and 'case' in 'kebab-case' as separate words.

vim.api.nvim_command([[
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
]])
-- " }}}

-- Emacs-like motion keys in insert mode {{{
-- -------------------------------------
inoremap { lhs = '<C-e>', rhs = '<C-o>$' }
inoremap { lhs = '<C-a>', rhs = '<C-o>0' }
inoremap { lhs = '<C-f>', rhs = '<C-o>l' }
inoremap { lhs = '<C-b>', rhs = '<C-o>h' }
inoremap { lhs = '<C-n>', rhs = '<C-o>j' }
inoremap { lhs = '<C-p>', rhs = '<C-o>k' }
inoremap { lhs = '<M-f>', rhs = '<C-o><Plug>CamelCaseMotion_w' }
inoremap { lhs = '<M-b>', rhs = '<C-o><Plug>CamelCaseMotion_b' }
-- }}}

-- Code completion {{{
-- -------------------
-- Completion backend is handed by the LSP servers of choice. We configure them
-- in the corresponding language section. UI is provided by nvim-cmp.

vim.opt.pumheight = 16
vim.opt.pumwidth = 32
vim.opt.pumblend = 5
vim.opt.completeopt = {'menu', 'menuone', 'noselect'}

require('blink.cmp').setup({
    completion = {
        menu = { winblend = 5, draw = { columns = { {'label'}, {'kind_icon', 'kind', gap = 1} } } },
        documentation = { auto_show = true },
        ghost_text = { enabled = false }
    },
    signature = { enabled = true },
    keymap = {
        ['<Tab>'] = { 'select_next', 'fallback' },
        ['<S-Tab>'] = { 'select_prev', 'fallback' },
        ['<CR>'] = { 'accept', 'fallback' }
    },
    sources = {
        default = {'lsp', 'path', 'snippets'},
        per_filetype = {
            sql = { 'dadbod', 'lsp', 'path', 'snippets' },
            mysql = { 'dadbod', 'lsp', 'path', 'snippets' },
            plsql = { 'dadbod', 'lsp', 'path', 'snippets' }
        },
        providers = {
            dadbod = {
                name = 'Dadbod',
                module = 'vim_dadbod_completion.blink'
            }
        }
    },
})

-- Debugging with DAP {{{
-- ----------------------
-- General settings
require('dap')

vim.fn.sign_define(
    'DapBreakpoint', {
        text = ' ',
        texthl = 'DiagnosticError',
        linehl = '',
        numhl = 'DiagnosticError'
    })
vim.fn.sign_define(
    'DapBreakpointCondition', {
        text = ' ',
        texthl = 'DiagnosticWarning',
        linehl = '',
        numhl = 'DiagnosticWarning'
    })
vim.fn.sign_define(
    'DapBreakpointRejected', {
        text = ' ',
        texthl = 'Comment',
        linehl = '',
        numhl = 'Comment'
    })
vim.fn.sign_define(
    'DapStopped', {
        text = ' ',
        texthl = 'DiagnosticHint',
        linehl = '',
        numhl = 'DiagnosticHint'
    })

-- Commands
vim.api.nvim_command('command! DapClearBreakpoints lua require("dap").clear_breakpoints()<CR>')

-- Keybindings
nnoremap { lhs = '<F5>', rhs = ':DapContinue<CR>' }
nnoremap { lhs = '<F9>', rhs = ':DapToggleBreakpoint<CR>' }
nnoremap { lhs = '<F10>', rhs = ':DapStepOver<CR>' }
nnoremap { lhs = '<F11>', rhs = ':DapStepInto<CR>' }
-- }}}

-- Automatic delimiter pairing {{{
-- -------------------------------
require('nvim-autopairs').setup {}
-- }}}

-- General LSP setup {{{
-- ---------------------
local signs = {
    Error = '',
    Warn = '',
    Hint = '',
    Info = '',
}

for type, icon in pairs(signs) do
  local hl = 'DiagnosticSign' .. type
  vim.fn.sign_define(hl, { text = icon, texthl = hl, numhl = 'LineNr' })
end

local on_attach = function(client, buffer)
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
        'n', '<leader>la', '<cmd>lua vim.lsp.buf.code_action()<CR>',
        { noremap = true, silent = true })
    vim.api.nvim_buf_set_keymap(
        buffer,
        'n', '<leader>lr', '<cmd>lua vim.lsp.buf.rename()<CR>',
        { noremap = true, silent = true })
    vim.api.nvim_buf_set_keymap(
        buffer,
        'n', 'K', '<cmd>lua vim.lsp.buf.hover()<CR>',
        { noremap = true, silent = true })
    vim.api.nvim_buf_set_keymap(
        buffer,
        'n', 'ge', '<cmd>lua vim.diagnostic.open_float({ scope = "line" })<CR>',
        { noremap = true, silent = true })

    -- Hide all semantic highlights
    for _, group in ipairs(vim.fn.getcompletion("@lsp", "highlight")) do
        vim.api.nvim_set_hl(0, group, {})
    end

    if client.server_capabilities.inlayHintProvider then
        vim.lsp.inlay_hint.enable(true)
    end

    client.server_capabilities.semanticTokensProvider = nil
end

vim.api.nvim_command('command! LspGotoDeclaration    lua vim.lsp.buf.declaration()<CR>')
vim.api.nvim_command('command! LspGotoDefinition     lua vim.lsp.buf.definition()<CR>')
vim.api.nvim_command('command! LspHover              lua vim.lsp.buf.hover()<CR>')
vim.api.nvim_command('command! LpsGotoImplementation lua vim.lsp.buf.implentation()<CR>')
vim.api.nvim_command('command! LspSignature          lua vim.lsp.buf.signature_help()<CR>')
vim.api.nvim_command('command! LspRename             lua vim.lsp.buf.rename()<CR>')
vim.api.nvim_command('command! LspCodeAction         lua vim.lsp.buf.code_action()<CR>')
-- }}}

-- Error diagnostics {{{
-- ---------------------
-- Better rendering in virtual text
-- require('lsp_lines').setup({})

-- By default show only sign column indicators, no virtual text
-- The hotkey toggles long-form error display (virtual lines)
local long_lines_visible = false
vim.diagnostic.config({
    virtual_text = false,
    virtual_lines = false
})

noremap {
    lhs = '<leader>el',
    rhs = function ()
        long_lines_visible = not long_lines_visible
        vim.diagnostic.config({
            virtual_text = false,
            virtual_lines = long_lines_visible
        })
    end,
    desc = 'Toggle long-form error format'
}

-- Error view
require('pqf').setup()

noremap {
    lhs = '<leader>ed',
    rhs = function()
        vim.diagnostic.setqflist()
        vim.cmd('copen')
    end,
    desc = 'Project diagnostics'
}
-- }}}

-- Filesystem tree {{{
-- -------------------
require('nvim-web-devicons').setup({
    color_icons = false
})

require('neo-tree').setup {
    enable_git_status = false,
    enable_diagnostics = false,
    filesystem = {
        follow_current_file = {
            enabled = true,
            leave_dirs_open = true
        },
        use_libuv_file_watcher = true,
        window = {
            position = "left",
            width = 0.25
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

nnoremap { lhs = '<leader>d', rhs = ':Neotree focus toggle<CR>', desc = 'Toggle directory tree' }
-- }}}

-- Language: VIM {{{
-- -----------------
-- It would be cool if editing this very config was done with the help of an
-- LSP server. Thankfully, there is such a server!
do
    local blink = require('blink.cmp')

    vim.lsp.config('vimls', {
        cmd = { 'vim-language-server', '--stdio' },
        filetypes = { 'vim' },
        root_markers = { '.git' },
        on_attach = on_attach,
        capabilities = blink.get_lsp_capabilities()
    })

    vim.api.nvim_create_autocmd('FileType', {
        pattern = 'vim',
        callback = function()
            vim.lsp.enable('vimls')
        end
    })
end
-- " }}}

-- Language: LUA {{{
-- -----------------
-- Some of the editing is done in Lua
do
    local blink = require('blink.cmp')

    vim.lsp.config('lua_ls', {
        cmd = { 'lua-language-server' },
        filetypes = { 'lua' },
        root_markers = { '.git', '.luarc.json' },
        on_attach = on_attach,
        capabilities = blink.get_lsp_capabilities(),
        settings = {
            Lua = {
                runtime = {
                    version = 'LuaJIT'
                },
                diagnostics = {
                    globals = { 'vim', 'use' }
                },
                workspace = {
                    library = vim.api.nvim_get_runtime_file("", true),
                    checkThirdParty = false
                },
                telemetry = {
                    enable = false
                }
            }
        }
    })

    vim.api.nvim_create_autocmd('FileType', {
        pattern = 'lua',
        callback = function()
            vim.lsp.enable('lua_ls')
        end
    })
end
-- }}}

-- Language: Python {{{
-- --------------------
-- LSP settings
do
    local blink = require('blink.cmp')

    vim.lsp.config('pyright', {
        cmd = { 'pyright-langserver', '--stdio' },
        filetypes = { 'python' },
        on_attach = on_attach,
        capabilities = blink.get_lsp_capabilities()
    })

    vim.api.nvim_create_autocmd('FileType', {
        pattern = 'python',
        callback = function()
            vim.lsp.enable('pyright')
        end
    })
end

-- DAP settings
do
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
end
-- }}}

-- Language: JavaScript and TypeScript {{{
-- ---------------------------------------
-- And sometimes I need to write frontend code as well.
-- LSP settings
do
    local blink = require('blink.cmp')

    vim.lsp.config('ts_ls', {
        cmd = {"/Users/ioreshnikov/.nvm/versions/node/v22.13.1/bin/typescript-language-server", "--stdio"},
        filetypes = { 'javascript', 'javascriptreact', 'typescript', 'typescriptreact' },
        root_markers = { 'main', 'tsconfig.json', 'package.json', '.git' },
        on_attach = on_attach,
        capabilities = blink.get_lsp_capabilities()
    })

    vim.api.nvim_create_autocmd('FileType', {
        pattern = { 'javascript', 'javascriptreact', 'typescript', 'typescriptreact' },
        callback = function()
            vim.lsp.enable('ts_ls')
        end
    })
end

-- Language: HTML and CSS {{{
-- --------------------------
-- Well, that's obvious
do
    local blink = require('blink.cmp')

    vim.lsp.config('html', {
        cmd = { 'vscode-html-language-server', '--stdio' },
        filetypes = { 'html' },
        root_markers = { '.git', 'package.json' },
        on_attach = on_attach,
        capabilities = blink.get_lsp_capabilities(),
    })

    vim.lsp.config('cssls', {
        cmd = { 'vscode-css-language-server', '--stdio' },
        filetypes = { 'css', 'scss', 'less' },
        root_markers = { '.git', 'package.json' },
        on_attach = on_attach,
        capabilities = blink.get_lsp_capabilities(),
    })

    vim.api.nvim_create_autocmd('FileType', {
        pattern = 'html',
        callback = function()
            vim.lsp.enable('html')
        end
    })

    vim.api.nvim_create_autocmd('FileType', {
        pattern = { 'css', 'scss', 'less' },
        callback = function()
            vim.lsp.enable('cssls')
        end
    })
end
-- }}}

-- Language: TeX {{{
-- -----------------
-- Occasionally I write LaTeX. It turns out there is an LSP mode for that as
-- well.
do
    local blink = require('blink.cmp')

    vim.lsp.config('texlab', {
        cmd = { 'texlab' },
        filetypes = { 'tex', 'bib', 'plaintex' },
        root_markers = { '.latexmkrc', '.git' },
        on_attach = on_attach,
        capabilities = blink.get_lsp_capabilities()
    })

    vim.api.nvim_create_autocmd('FileType', {
        pattern = { 'tex', 'bib', 'plaintex' },
        callback = function()
            vim.lsp.enable('texlab')
        end
    })
end

vim.g.unicoder_no_map = true
nnoremap { lhs = '<C-\\>', rhs = ':call unicoder#start(0)<CR>' }
inoremap { lhs = '<C-\\>', rhs = '<C-o>:call unicoder#start(1)<CR>' }
vnoremap { lhs = '<C-\\>', rhs = ':<C-u>call unicoder#selection()<CR>' }
-- }}}

-- Language: Rust {{{
-- ------------------
-- I need to learn a system programming language and it's definitely not C/C++
-- :)
do
    local blink = require('blink.cmp')

    vim.lsp.config('rust_analyzer', {
        cmd = { 'rust-analyzer' },
        filetypes = { 'rust' },
        root_markers = { 'Cargo.toml', 'rust-project.json' },
        on_attach = on_attach,
        capabilities = blink.get_lsp_capabilities()
    })

    vim.api.nvim_create_autocmd('FileType', {
        pattern = 'rust',
        callback = function()
            vim.lsp.enable('rust_analyzer')
        end
    })
end
-- }}}

-- Language: SQL {{{
-- -----------------
do
    local blink = require('blink.cmp')

    vim.lsp.config('sqlls', {
        cmd = { 'sql-language-server', 'up', '--method', 'stdio' },
        filetypes = { 'sql', 'mysql' },
        root_markers = { '.git' },
        on_attach = on_attach,
        capabilities = blink.get_lsp_capabilities()
    })

    vim.api.nvim_create_autocmd('FileType', {
        pattern = { 'sql', 'mysql' },
        callback = function()
            vim.lsp.enable('sqlls')
        end
    })
end
-- }}}

-- Language: Markdown {{{
-- ----------------------
do
    local blink = require('blink.cmp')

    vim.lsp.config('markdown_oxide', {
        cmd = { 'markdown-oxide' },
        filetypes = { 'markdown' },
        root_markers = { '.obsidian' },
        on_attach = on_attach,
        capabilities = blink.get_lsp_capabilities()
    })

    vim.api.nvim_create_autocmd('FileType', {
        pattern = 'markdown',
        callback = function()
            vim.lsp.enable('markdown_oxide')
        end
    })
end
-- }}}

-- REST client {{{
-- ---------------
require('rest-nvim').setup()
noremap {
    lhs = '<leader>rr',
    rhs = '<Plug>RestNvim<CR>',
    desc = 'Run buffer with RESTClient'
}
-- }}}

-- Database client {{{
-- -------------------
vim.g.db_ui_use_nerd_fonts = 1
vim.g.db_ui_show_database_icon = 1
vim.g.db_ui_winwidth = 40
vim.g.db_ui_save_location = vim.fn.stdpath("data") .. "/db_ui"
vim.g.db_ui_execute_on_save = 0  -- Don't auto-execute on save

noremap {
    lhs = '<leader>dbt',
    rhs = ':DBUI<CR>',
    desc = 'Toggle database UI'
}

-- Custom keybindings for query execution
vim.api.nvim_create_autocmd('FileType', {
    pattern = { 'sql', 'mysql', 'plsql' },
    callback = function(ev)
        -- Override default <Leader>W with our own mapping
        vim.keymap.set('n', '<leader>W', '<Nop>', { buffer = ev.buf })
        vim.keymap.set('v', '<leader>W', '<Nop>', { buffer = ev.buf })

        -- Our custom mappings
        vim.keymap.set('n', '<leader>dbr', '<Plug>(DBUI_ExecuteQuery)', {
            buffer = ev.buf,
            silent = true,
            desc = 'Run query'
        })
        vim.keymap.set('v', '<leader>dbr', '<Plug>(DBUI_ExecuteQuery)', {
            buffer = ev.buf,
            silent = true,
            desc = 'Run selected query'
        })
        vim.keymap.set('n', '<leader>dbs', '<Plug>(DBUI_SaveQuery)', {
            buffer = ev.buf,
            silent = true,
            desc = 'Save query'
        })
    end
})
-- }}}

-- Docker {{{
-- ----------
vim.api.nvim_command([[
    autocmd BufRead,BufNewFile Dockerfile.* set filetype=dockerfile
]])
-- }}}

-- Random things {{{
-- -----------------
-- A faster way to save files
noremap { lhs = '<leader>w', rhs = ':w<CR>', desc = 'Write file' }

-- And center the current line on screen (and remove highlight)
nnoremap { lhs = '<C-l>', rhs = 'zz:noh<CR>' }
inoremap { lhs = '<C-l>', rhs = '<ESC>zz:noh<CR>a' }

-- Clear message area after a timeout
vim.opt.updatetime = 2000
vim.api.nvim_command([[autocmd CursorHold * echon '']])

-- Close a buffer
nnoremap {
    lhs = '<leader>k',
    rhs = ':bp \\| sp \\| bn \\| bd<CR>',
    desc = 'Close buffer'
}

-- Close all buffers except current
nnoremap {
    lhs = '<leader>K',
    rhs = ':%bd \\| e# \\| bd#<CR>',
    desc = 'Close all buffers except current'
}

-- Disable startup message
vim.opt.shm = vim.opt.shm + 'I'

-- Copy publically visible url to the current file
do
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

    local function git_root()
        return exec('git rev-parse --show-toplevel')
    end

    local function current_location_url()
        local Path = require('plenary.path')

        local absolute_path = vim.api.nvim_buf_get_name(0)
        local cwd = git_root()
        local relative_path = Path:new(absolute_path):make_relative(cwd)
        -- XXX: Broken and returs absolut path

        local repo = git_current_repo()
        local hash = git_current_hash()

        local linenr = vim.api.nvim_win_get_cursor(0)[1]

        local url =
            'https://github.com/' .. repo ..
            '/blob/' .. hash .. '/' .. relative_path ..
            '#L' .. linenr
        return url
    end

    local function current_location_markdown_url()
        local url = current_location_url()
        return '[](' .. url .. ')'
    end

    local function copy_current_location_url()
        local url = current_location_url()
        vim.fn.setreg('*', url)
    end

    local function copy_current_location_markdown_url()
        local url = current_location_markdown_url()
        vim.fn.setreg('*', url)
    end

    nnoremap { lhs = '<leader>lgl', rhs = copy_current_location_url, desc = 'GitHub link here (text)' }
    nnoremap { lhs = '<leader>lgm', rhs = copy_current_location_markdown_url, desc = 'GitHub link here (md)' }
end
-- }}}

-- Neovide specific GUI settings {{{
-- ---------------------------------
vim.g.neovide_input_macos_alt_is_meta = true
vim.g.neovide_hide_mouse_when_typing = 1
vim.g.neovide_cursor_animation_length = 0.05
vim.g.neovide_cursor_vfx_mode = 'railgun'

do
    local font_family = 'FiraCode Nerd Font Mono'
    local font_sizes = {12, 15, 18}

    local font_size_idx = 0

    local function toggle_fontsize()
        font_size_idx = (font_size_idx + 1) % #font_sizes
        local font_size = font_sizes[font_size_idx + 1]
        vim.opt.guifont = {font_family, ':h' .. font_size}
    end

    toggle_fontsize()

    noremap {
        lhs = '<F12>',
        rhs = function ()
            vim.g.neovide_fullscreen = not vim.g.neovide_fullscreen
        end
    }
    noremap {
        lhs = '<F7>',
        rhs = toggle_fontsize
    }
end
-- }}}

-- Color scheme {{{
-- ----------------
vim.api.nvim_command([[
    set termguicolors
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
]])
-- }}}

-- Writing mode {{{
-- ----------------
require('zen-mode').setup({
    window = {
        backdrop = 1.0,
        width = 78,
        height = 0.90,
        options = {
            cursorline = false,
            number = false,
            relativenumber = false,
            signcolumn = "no"
        }
    }
})

noremap {
    lhs = '<F12>',
    rhs = ':ZenMode<CR>',
    desc = 'Toggle writing mode'
}
-- }}}
