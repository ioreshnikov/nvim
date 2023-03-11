-- Leader key {{{
-- --------------
-- Since `map` and `remap` evaluate `<leader>` definition eagerly (i.e. not in
-- a lazy manner), we have to set up leader key as soon as possible.
vim.g.mapleader = ' ';
-- }}}

-- Plugins {{{
-- -----------
require('packer').startup(function ()

-- Let packer manage itself
use 'wbthomason/packer.nvim'

-- Text icons
use 'kyazdani42/nvim-web-devicons'

-- Fuzzy everything
use 'nvim-lua/plenary.nvim'
use 'nvim-telescope/telescope.nvim'
use { 'nvim-telescope/telescope-fzf-native.nvim', run = 'make' }
use 'nvim-telescope/telescope-project.nvim'
use 'tami5/sqlite.lua'

-- Modern syntax highlight with `tree-sitter`
use { 'nvim-treesitter/nvim-treesitter', run = ':TSUpdate' }

-- Text objects with treesitter
use 'nvim-treesitter/nvim-treesitter-textobjects'

-- Structural searhc and replace
use 'cshuaimin/ssr.nvim'

-- Managing Git repos
use 'TimUntersberger/neogit'

-- Code completion backend through LSP servers
use 'neovim/nvim-lspconfig'

-- Code completion frontend with `nvim-cmp`
use 'hrsh7th/cmp-nvim-lsp'
use 'hrsh7th/cmp-buffer'
use 'hrsh7th/cmp-path'
use 'hrsh7th/cmp-cmdline'
use 'hrsh7th/cmp-emoji'
use 'hrsh7th/nvim-cmp'

use 'onsails/lspkind-nvim'
use 'ray-x/lsp_signature.nvim'

-- Vim global completion in lua lsp
use 'folke/neodev.nvim'

-- Snippets
use 'rafamadriz/friendly-snippets'
use 'L3MON4D3/LuaSnip'
use 'saadparwaiz1/cmp_luasnip'

-- Interactive debugging through DAP
use 'mfussenegger/nvim-dap'

-- Use a custom statusline
use 'nvim-lualine/lualine.nvim'

-- A custom tab line
use 'alvarosevilla95/luatab.nvim'

-- Toggleable terminal
use 'akinsho/toggleterm.nvim'

-- Which key
use 'folke/which-key.nvim'

-- Commenting
use 'tpope/vim-commentary'

-- Surround
use 'machakann/vim-sandwich'

-- Sub-word motion
use 'bkad/CamelCaseMotion'

-- Case coercion
use 'tpope/vim-abolish'

-- Auto-pairing
use 'windwp/nvim-autopairs'

-- TeX
use 'lervag/vimtex'

-- Prettier javascript
use { 'prettier/vim-prettier', run = 'yarn install --frozen-lockfile --production' }

-- Unicode symbols entry
use 'joom/latex-unicoder.vim'

-- LSP errors
use "https://git.sr.ht/~whynothugo/lsp_lines.nvim"
use 'folke/trouble.nvim'

-- TODO marks
use 'folke/todo-comments.nvim'

-- Indentation guides
use 'lukas-reineke/indent-blankline.nvim'

-- Indent level autodetection
use 'timakro/vim-yadi'

-- Automatically change cwd to the root of the project
use 'ahmedkhalf/project.nvim'

-- Tree viewer
use 'MunifTanjim/nui.nvim'
use { 'nvim-neo-tree/neo-tree.nvim', run = 'v2.x' }

-- REST client
use 'NTBBloodbath/rest.nvim'

-- Org-mode
use 'nvim-orgmode/orgmode'

-- Live preview commands
use 'smjonas/live-command.nvim'

-- Theming
use 'rktjmp/lush.nvim'

-- My custom port of Helix editor color theme. Really purple
use 'ioreshnikov/helix'
use 'ioreshnikov/solarized'

-- Automatically switch background on sunset/sunrise
use 'JManch/sunset.nvim'

end)
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
-- aesthetical reasons.
vim.api.nvim_command([[
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
vim.opt.showbreak='⤷ '
-- Do not wrap by default. This is overriden in mode-by-mode basis.
vim.opt.wrap = true
-- }}}

-- Folds {{{
-- ---------
-- Folds are occasionally useful. I wish I could use tree-sitter aware folds,
-- but as of now they're glitchy and tend to randomly collapse when you edit a
-- region. Therefore I resort to good old fold by marker.
vim.opt.foldmethod = 'marker'
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

-- Tab line look and feel {{{
-- --------------------------
--
-- There are multiple fancy tabline plugins out there. I don't like any of them,
-- since pretty much all of them inherit a highly opinionated approach to tabs
-- by automatically creating a tab per buffer every time you open a buffer.
--
-- This forces you to keep only a very limited number of open buffers and this
-- is just not how I work. I like to keep everything related to the current task
-- in the background and I like to keep everything necessary at the moment in sight.
--
-- In other words, my context >> what I am focused at the moment.

do
    local luatab = require('luatab')
    local highlight = require('luatab.highlight')

    luatab.setup({
        modified = function (bufnr)
            -- TODO: Add highlight
            return vim.fn.getbufvar(bufnr, '&modified') == 1 and '󰇘 ' or ''
        end,
        cell = function(index)
            local isSelected = vim.fn.tabpagenr() == index
            local buflist = vim.fn.tabpagebuflist(index)
            local winnr = vim.fn.tabpagewinnr(index)
            local bufnr = buflist[winnr]

            local tabhi = (isSelected and 'TabLineSel' or 'TabLine')
            local tabhl = '%#' .. tabhi .. '#'

            local crossfg = highlight.extract_highlight_colors('TabLineFill', 'fg')
            local crossbg = highlight.extract_highlight_colors('TabLineSel', 'bg')
            local crosshi = highlight.create_component_highlight_group(
                {fg = crossfg, bg = crossbg},
                'TablineClose'
            )
            local crosshl = crosshi and ('%#' .. crosshi .. '#') or ''
            local cross =  crosshl .. '%999X × ' .. tabhl

            return tabhl .. '%' .. index .. 'T  ' ..
                luatab.helpers.modified(bufnr) ..
                luatab.helpers.devicon(bufnr, isSelected) ..
                luatab.helpers.title(bufnr) ..
                (isSelected and cross or ' ') ..
                '%T'
        end,
        tabline = function()
            local line = ''
            for i = 1, vim.fn.tabpagenr('$'), 1 do
                line = line .. luatab.helpers.cell(i)
            end
            line = line .. '%#TabLineFill#%='
            return line
        end
    })
end
-- }}}

-- Movement on wrapped lines {{{
-- -----------------------------
-- I am using soft line-wrap everywhere. The default navigation commands in vim
-- work on physical lines, not wrapped ones. This is really inconvinient. This
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
        patterns = { 'main', unpack(defaults.patterns) }
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
            height = 0.5,
            prompt_position = 'top',
        },
        prompt_prefix = '   ',
        prompt_title = false,
        results_title = ' ',
        selection_caret = '  ',
        sorter = sorters.get_fzy_sorter,
        sorting_strategy = 'ascending'
    },
    extensions = {
        file_browser = {
            dir_icon = '',
            hidden = true,
        },
        fzf = {
            fuzzy = true,
            override_generic_sorter = true,
            override_file_sorter = true
        },
        project = {
            base_dirs = {
                { '~/repos/', max_depth = 3 },
                { '~/.local/share/nvim/site/pack/packer/start', max_depth = 2 },
                { '~/.config/nvim' }
            },

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
    rhs = require('telescope.builtin').buffers,
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
}

vim.api.nvim_command([[hi link TelescopeNormal NormalFloat]])
vim.api.nvim_command([[hi link TelescopeBorder NormalFloat]])
vim.api.nvim_command([[hi link TelescopePromptPrefix Comment]])
vim.api.nvim_command([[hi link TelescopeTitle Ignore]])
-- }}}

-- Terminal {{{
-- ------------
-- Automatically enter insert mode when entering a terminal window.
-- Automatically switch to normal on exit.
vim.api.nvim_command([[autocmd WinEnter term://* startinsert]])
vim.api.nvim_command([[autocmd WinLeave term://* stopinsert]])
-- SEE: https://github.com/neovim/neovim/pull/16596

-- Open terminal in a toggle
require('toggleterm').setup {
    highlights = {
        Normal = { guifg = "#ffffff", guibg = "#000000" },
        CursorLine = { guifg = "#ffffff", guibg = "#181818" },
        StatusLine = { link = 'StatusLine' },
        StatusLineNC = { link = 'StatusLineNC' },
    },
    shade_terminals = false,
    size = function (term)
        if term.direction == 'horizontal' then
            return 25
        elseif term.direction == 'vertical' then
            return 80
        else
            return 25
        end
    end
}

-- Setup DevIcons icon for ToggleTerm
require('nvim-web-devicons').set_icon({
    toggleterm = {
        icon = '',
        name = 'Terminal'
    }
})

noremap {
    lhs = '<leader>ts',
    rhs = function ()
        require('toggleterm').toggle(1, nil, nil, 'horizontal')
    end,
    desc = 'Terminal horizontal'
}
noremap {
    lhs = '<leader>tv',
    rhs = function ()
        require('toggleterm').toggle(1, nil, nil, 'vertical')
    end,
    desc = 'Terminal vertical'
}
noremap {
    lhs = '<leader>tt',
    rhs = function ()
        require('toggleterm').toggle(1, nil, nil, 'tab')
    end,
    desc = 'Terminal in a tab'
}
-- " }}}

-- Which key {{{
-- -------------
do
    local wk = require('which-key')

    wk.setup({
        icons = {
            breadcrumbs = ">",
            separator = "->",
            group = ""
        }
    })

    wk.register({
        ['<leader>e']  = { name = 'Diagnostics/' },
        ['<leader>f']  = { name = 'Telescope/' },
        ['<leader>fs'] = { name = 'Bolt/' },
        ['<leader>r']  = { name = 'REST/' },
        ['<leader>t']  = { name = 'Terminal/' },
        ['<leader>v']  = { name = 'Evaluate/' },
        ['<leader>l']  = { name = 'Link/' },
        ['<leader>s']  = { name = 'Swap/' },
    })
end
-- }}}

-- Command line {{{
-- ----------------
-- It's possible now to hide command line and it looks neat!
vim.opt.cmdheight = 0
-- }}}

-- Status line {{{
-- ---------------
do
    local filename = require('lualine.components.filename'):extend()

    filename.apply_icon = require('lualine.components.filetype').apply_icon

    local modesymbol = {
        ['NORMAL']   = ' NOR',
        ['INSERT']   = ' INS',
        ['VISUAL']   = 'ﱓ VIS',
        ['V-LINE']   = ' VIS',
        ['V-BLOCK']  = ' VIS',
        ['TERMINAL'] = ' ZSH',
        ['COMMAND']  = ' CMD',
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
            disabled_filetypes = {}
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
            },
            lualine_x = {
                'branch',
                'fileformat',
                'encoding',
            },
            lualine_y = {
                {
                    'diagnostics',
                    colored = true,
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
end
-- }}}

-- Indentation guide {{{
-- ---------------------
-- XXX: The usability is sadly not that great due to a long-standing bug in
-- neovim:
--     https://github.com/neovim/neovim/issues/6591
-- The setup is minimalistic -- I mostly disable the indentation guides in the
-- modes I don't want them to see.
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
-- " }}}

-- Git {{{
-- -------
-- Almost no setup required
require('neogit').setup {
    commit_popup = { kind = 'vsplit' },
    disable_commit_confirmation = true,
    disable_hint = true,
    signs = {
        section = {' ' , ' '},
        item = {' ' , ' '},
    }
}

-- A simple key combination for opening git status anywhere
noremap { lhs = '<leader>g', rhs = require('neogit').open, desc = 'Neogit' }
-- " }}}

-- Tree sitter {{{
-- ---------------

-- The section below configures `tree-sitter` to be used for syntax
-- highlighting, selection, indentation and automatic delimiters pairing.
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

-- Snippets {{{
-- ------------
require("luasnip.loaders.from_vscode").lazy_load()
-- }}}

-- Code completion {{{
-- -------------------
-- Completion backend is handed by the LSP servers of choice. We configure them
-- in the corresponding language section. UI is provided by nvim-cmp.

vim.opt.pumheight = 16
vim.opt.pumwidth = 32
vim.opt.completeopt = {'menu', 'menuone', 'noselect'}

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
            { name = 'path' }
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
    hint_prefix = ' ',
    handler_opts = {
        border = "none"
    }
}
-- }}}

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
nnoremap { lhs = '<leader>oc', rhs = ':DapContinue<CR>' }
nnoremap { lhs = '<leader>ot', rhs = ':DapTerminate<CR>' }
nnoremap { lhs = '<leader>ob', rhs = ':DapToggleBreakpoint<CR>' }
nnoremap { lhs = '<leader>os', rhs = ':DapStepOver<CR>' }
nnoremap { lhs = '<leader>oi', rhs = ':DapStepInto<CR>' }
nnoremap { lhs = '<leader>oo', rhs = ':DapStepOut<CR>' }
nnoremap { lhs = '<leader>or', rhs = ':DapToggleRepl<CR>' }
nnoremap { lhs = '<leader>oq', rhs = ':DapClearBreakpoints<CR>' }

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
    Error = ' ',
    Warn = ' ',
    Hint = ' ',
    Info = ' ',
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
        'n', 'ca', '<cmd>lua vim.lsp.buf.code_action()<CR>',
        { noremap = true, silent = true })
    vim.api.nvim_buf_set_keymap(
        buffer,
        'n', 'K', '<cmd>lua vim.lsp.buf.hover()<CR>',
        { noremap = true, silent = true })
    vim.api.nvim_buf_set_keymap(
        buffer,
        'n', 'ge', '<cmd>lua vim.diagnostic.open_float({ scope = "line" })<CR>',
        { noremap = true, silent = true })
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
require('lsp_lines').setup {}

-- We disable it by default, but we add to a shortcut to toggle from short to
-- long format
local short_form_errors = true
vim.diagnostic.config({
    virtual_text = short_form_errors,
    virtual_lines = not short_form_errors
})

noremap {
    lhs = '<leader>el',
    rhs = function ()
        short_form_errors = not short_form_errors
        vim.diagnostic.config({
            virtual_text = short_form_errors,
            virtual_lines = not short_form_errors
        })
    end,
    desc = 'Toggle long-form error format'
}

-- Error view
require('trouble').setup {
    indent_lines = false
}

noremap { lhs = '<leader>ef', rhs = ':TroubleToggle document_diagnostics<CR>', desc = 'File errors' }
noremap { lhs = '<leader>ew', rhs = ':TroubleToggle workspace_diagnostics<CR>', desc = 'Workspace errors' }

vim.api.nvim_command([[hi link TroubleNormal LspTroubleNormal]])
-- }}}

-- TODO comments {{{
-- -----------------
-- A neat utility for highlighting the comment-keywords.

-- NOTE: Before we set it up, it's a good idea to disable a couple of builtin
-- highlight groups.
vim.api.nvim_command([[
    hi clear Todo
    hi clear WarningMsg
]])

require('todo-comments').setup {
    keywords = {
        FIX = {
            icon = ' ',
            color = 'error',
            alt = { 'FIXME', 'BUG', 'FIXIT', 'ISSUE' },
        },
        TODO = {
            icon = ' ',
            color = 'info'
        },
        DONE = {
            icon = ' ',
            color = 'hint'
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
    },
    highlight = {
        after = '',
        keyword = 'bg'
    }
}

noremap { lhs = '<leader>et', rhs = ':TodoTrouble<CR>', desc = 'Todo notes' }
-- }}}

-- Filesystem tree {{{
-- -------------------
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
        },
        window = {
            position = "left",
            width = 50
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
    local config = require('lspconfig')
    local cmplsp = require('cmp_nvim_lsp')

    config.vimls.setup {
        on_attach = on_attach,
        capabilities = cmplsp.default_capabilities()
    }
end
-- " }}}

-- Language: LUA {{{
-- -----------------
-- Some of the editing is done in Lua
do
    require("neodev").setup({})

    local config = require('lspconfig')
    local cmplsp = require('cmp_nvim_lsp')

    config.lua_ls.setup {
        on_attach = on_attach,
        capabilities = cmplsp.default_capabilities(),
        settings = {
            globals = { 'vim' }
        }
        -- settings = {
        --     Lua = {
        --         runtime = {
        --             version = 'LuaJIT'
        --         },
        --         diagnostics = {
        --             globals = { 'vim' }
        --         },
        --         workspace = {
        --             library = vim.api.nvim_get_runtime_file("", true)
        --         },
        --         telemetry = {
        --             enabled = false
        --         }
        --     }
        -- }
    }
end
-- }}}

-- Language: Python {{{
-- --------------------
-- LSP settings
do
    local config = require('lspconfig')
    local cmplsp = require('cmp_nvim_lsp')

    config.pyright.setup {
        on_attach = on_attach,
        capabilities = cmplsp.default_capabilities()
    }
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
    local config = require('lspconfig')
    local cmplsp = require('cmp_nvim_lsp')

    config.tsserver.setup {
        on_attach = on_attach,
        capabilities = cmplsp.default_capabilities(),
        root_dir = config.util.root_pattern('main')
    }
end

-- DAP settings
do
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

    dap.configurations.typescript = {
        {
            name = 'Attach to process',
            type = 'node2',
            request = 'attach',
            processId = require('dap.utils').pick_process
        },
    }
end

-- " }}}

-- Language: Ember.js {{{
-- ----------------------
-- do
--     local lsp = require('lspconfig')
--     local coq = require('coq')

--     lsp.ember.setup{
--         on_attach=ioextra.on_attach,
--         unpack(coq.lsp_ensure_capabilities())
--     }
-- end
-- }}}

-- Language: HTML and CSS {{{
-- --------------------------
-- Well, that's obvious
do
    local config = require('lspconfig')
    local cmplsp = require('cmp_nvim_lsp')

    config.html.setup {
        on_attach = on_attach,
        capabilities = cmplsp.default_capabilities()
    }
    config.cssls.setup {
        on_attach = on_attach,
        capabilities = cmplsp.default_capabilities()
    }
end
-- }}}

-- Language: TeX {{{
-- -----------------
-- Occasionally I write LaTeX. It turns out there is an LSP mode for that as
-- well.
do
    local config = require('lspconfig')
    local cmplsp = require('cmp_nvim_lsp')

    config.texlab.setup {
        on_attach = on_attach,
        capabilities = cmplsp.default_capabilities()
    }
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
    local config = require('lspconfig')
    local cmplsp = require('cmp_nvim_lsp')

    config.rust_analyzer.setup {
        on_attach = on_attach,
        capabilities = cmplsp.default_capabilities()
    }
end
-- }}}

-- Language: GO {{{
-- ----------------
-- Eh, why not
do
    local config = require('lspconfig')
    local cmplsp = require('cmp_nvim_lsp')

    config.gopls.setup {
        on_attach = on_attach,
        capabilities = cmplsp.default_capabilities()
    }
end
-- }}}

-- Language: PHP {{{
-- -----------------
-- I am shocked as well :)
do
    local config = require('lspconfig')
    local cmplsp = require('cmp_nvim_lsp')

    config.phpactor.setup {
        on_attach = on_attach,
        capabilities = cmplsp.default_capabilities()
    }
end
-- }}}

-- Language: SQL {{{
-- -----------------
do
    local config = require('lspconfig')
    local cmplsp = require('cmp_nvim_lsp')

    config.sqlls.setup {
        on_attach = on_attach,
        capabilities = cmplsp.default_capabilities()
    }
end
-- }}}

-- Language: Markdown {{{
-- ----------------------
do
    local config = require('lspconfig')
    local cmplsp = require('cmp_nvim_lsp')

    config.marksman.setup {
        on_attach = on_attach,
        capabilities = cmplsp.default_capabilities()
    }
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

-- Docker {{{
-- ----------
vim.api.nvim_command([[
    autocmd BufRead,BufNewFile Dockerfile.* set filetype=dockerfile
]])
-- }}}

-- Org-mode {{{
-- --------
require('orgmode').setup {
    org_default_notes_file = '~/Org/Index.org',
    org_todo_keywords = { 'TODO', 'LIVE', '|', 'DONE', 'FAIL', 'ABRT' },
    org_hide_emphasis_markers = true,
    org_capture_templates = {
        s = {
            description = 'Standup',
            template = '* %(return os.date("%A, %d %B %Y", os.time() + 60 * 60 * 24))\n\n  *Yesterday*\n\n  - %?\n\n  *Today*\n\n  - \n\n',
            target = '~/Org/Index.org',
            headline = 'Standups',
        },
        a = {
            description = 'Code annotation',
            template = '* %? \n\n  %a\n',
            target = '~/Org/Annotations.org',
            headline = 'Annotations',
        },
    },
}
-- }}}

-- Live command preview {{{
-- --------------------
require('live-command').setup {
    commands = {
        Norm = { cmd = "norm" }
    }
}
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

    local function copy_current_location_orgmode_url()
        local path = vim.api.nvim_buf_get_name(0)
        local linenr = vim.api.nvim_win_get_cursor(0)[1]
        local url = string.format('[[file:%s +%s]]', path, linenr);
        vim.fn.setreg('*', url);
    end

    nnoremap { lhs = '<leader>lgl', rhs = copy_current_location_url, desc = 'GitHub link here (text)' }
    nnoremap { lhs = '<leader>lgm', rhs = copy_current_location_markdown_url, desc = 'GitHub link here (md)' }
    nnoremap { lhs = '<leader>lo', rhs = copy_current_location_orgmode_url, desc = 'Org-mode link here' }
end
-- }}}

-- Neovide specific GUI settings {{{
-- ---------------------------------
vim.g.neovide_input_macos_alt_is_meta = true
vim.g.neovide_hide_mouse_when_typing = 1
vim.g.neovide_cursor_animation_length = 0.05
vim.g.neovide_cursor_vfx_mode = 'railgun'

local bigfont = false

local function toggle_fontsize()
    bigfont = not bigfont
    if bigfont then
        vim.opt.guifont = {'JetBrainsMono Nerd Font', ':h14'}
    else
        vim.opt.guifont = {'JetBrainsMono Nerd Font', ':h17'}
    end
end


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
-- }}}

-- Color scheme {{{
-- ----------------
vim.api.nvim_command([[
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

require('sunset').setup({
    latitude  = 52.5200,
    longitude = 13.4050
})
-- }}}
