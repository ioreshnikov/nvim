local M = {}

---@class SymbolSidebarConfig
---@field keymap string
---@field window { width: number|string|fun(): number|string }

---@class SymbolSidebarEntry
---@field line integer
---@field column integer
---@field text string
---@field depth integer
---@field order integer
---@field range { start: { line: integer, character: integer }, end_: { line: integer, character: integer } }

---@class SymbolSidebarState
---@field buf integer?
---@field win integer?
---@field source_buf integer?
---@field source_win integer?
---@field client_id integer?
---@field entries SymbolSidebarEntry[]
---@field active integer?
---@field request integer
---@field refresh_pending integer
---@field opening boolean

---@type SymbolSidebarConfig
local config = {
    keymap = '<leader>o',
    window = {
        width = 40,
    },
}

---@type SymbolSidebarState
local state = {
    entries = {},
    request = 0,
    refresh_pending = 0,
    opening = false,
}

local syntax_namespace = vim.api.nvim_create_namespace('symbol-sidebar-syntax')
local active_namespace = vim.api.nvim_create_namespace('symbol-sidebar-active')

local structural_kinds = {}
for _, name in ipairs({
    'Module',
    'Namespace',
    'Package',
    'Class',
    'Method',
    'Constructor',
    'Enum',
    'Interface',
    'Function',
    'Struct',
}) do
    structural_kinds[vim.lsp.protocol.SymbolKind[name]] = true
end

local function sidebar_is_open()
    return state.win ~= nil and vim.api.nvim_win_is_valid(state.win)
end

local function source_is_valid()
    return state.source_buf ~= nil
        and state.source_win ~= nil
        and vim.api.nvim_buf_is_valid(state.source_buf)
        and vim.api.nvim_win_is_valid(state.source_win)
        and vim.api.nvim_win_get_buf(state.source_win) == state.source_buf
end

local function resolve_width()
    local width = config.window.width
    if type(width) == 'function' then
        width = width()
    end

    local percentage = type(width) == 'string' and width:sub(-1) == '%'
    if percentage then
        width = tonumber(width:sub(1, -2))
        width = width and width / 100 or nil
    else
        width = tonumber(width)
        percentage = width ~= nil and width > 0 and width < 1
    end

    width = width or 40
    if percentage then
        width = math.floor(vim.o.columns * width)
    end

    return math.max(1, math.min(math.floor(width), vim.o.columns - 1))
end

---@param line string
---@param character integer
---@param encoding string
---@return integer
local function byte_index(line, character, encoding)
    local ok, result = pcall(vim.str_byteindex, line, encoding, character, false)
    if ok then
        return result
    end
    return math.min(character, #line)
end

---@param bufnr integer
---@param row integer
---@return string
local function get_line(bufnr, row)
    return vim.api.nvim_buf_get_lines(bufnr, row, row + 1, false)[1] or ''
end

---@param line string
---@return string
local function declaration_line(line)
    line = line:gsub('%s*{%s*}%s*;?%s*$', '')
    return line:gsub('%s*{%s*$', '')
end

---@param position lsp.Position
---@param encoding string
---@return { line: integer, character: integer }
local function position_to_bytes(position, encoding)
    local line = get_line(state.source_buf, position.line)
    return {
        line = position.line,
        character = byte_index(line, position.character, encoding),
    }
end

---@param symbols lsp.DocumentSymbol[]|lsp.SymbolInformation[]
---@param encoding string
---@return SymbolSidebarEntry[]
local function collect_entries(symbols, encoding)
    local entries = {}
    local order = 0

    ---@param items lsp.DocumentSymbol[]|lsp.SymbolInformation[]
    ---@param depth integer
    local function visit(items, depth)
        for _, symbol in ipairs(items or {}) do
            local range = symbol.range or symbol.location and symbol.location.range
            local selection = symbol.selectionRange or range

            if range and selection and structural_kinds[symbol.kind] then
                order = order + 1
                local row = selection.start.line
                table.insert(entries, {
                    line = row + 1,
                    column = position_to_bytes(selection.start, encoding).character,
                    text = declaration_line(get_line(state.source_buf, row)),
                    depth = depth,
                    order = order,
                    range = {
                        start = position_to_bytes(range.start, encoding),
                        end_ = position_to_bytes(range['end'], encoding),
                    },
                })
            end

            if symbol.children then
                visit(symbol.children, depth + 1)
            end
        end
    end

    visit(symbols, 0)
    table.sort(entries, function(left, right)
        if left.line ~= right.line then
            return left.line < right.line
        end
        if left.column ~= right.column then
            return left.column < right.column
        end
        return left.order < right.order
    end)
    return entries
end

---@param source_row integer
---@param sidebar_row integer
---@param sidebar_line string
local function copy_treesitter_highlights(source_row, sidebar_row, sidebar_line)
    local highlighter = vim.treesitter.highlighter.active[state.source_buf]
    if not highlighter then
        return
    end

    local line = get_line(state.source_buf, source_row)
    pcall(function()
        highlighter.tree:for_each_tree(function(tree, language_tree)
            if not tree then
                return
            end

            local root = tree:root()
            local root_start, _, root_end = root:range()
            if source_row < root_start or source_row > root_end then
                return
            end

            local highlights = highlighter:get_query(language_tree:lang())
            local query = highlights:query()
            if not query then
                return
            end

            for capture, node, metadata in query:iter_captures(
                root,
                state.source_buf,
                source_row,
                source_row + 1
            ) do
                local capture_metadata = metadata and metadata[capture]
                local range = vim.treesitter.get_range(node, state.source_buf, capture_metadata)
                local start_row, start_col = range[1], range[2]
                local end_row, end_col = range[4], range[5]

                if start_row <= source_row and end_row >= source_row then
                    start_col = start_row < source_row and 0 or start_col
                    end_col = end_row > source_row and #line or end_col
                    start_col = math.min(start_col, #sidebar_line)
                    end_col = math.min(end_col, #sidebar_line)

                    local highlight = highlights:get_hl_from_capture(capture)
                    if highlight and highlight ~= 0 and start_col < end_col then
                        local priority = metadata and metadata.priority
                            or capture_metadata and capture_metadata.priority
                            or vim.hl.priorities.treesitter
                        vim.api.nvim_buf_set_extmark(state.buf, syntax_namespace, sidebar_row, start_col, {
                            end_col = end_col,
                            hl_group = highlight,
                            priority = tonumber(priority),
                        })
                    end
                end
            end
        end)
    end)
end

local function update_number_width()
    if not source_is_valid() or not sidebar_is_open() then
        return
    end

    local source_width = vim.wo[state.source_win].numberwidth
    local digits = #tostring(vim.api.nvim_buf_line_count(state.source_buf)) + 1
    vim.wo[state.win].numberwidth = math.max(source_width, digits)
end

local function sync_source_appearance()
    vim.bo[state.buf].syntax = vim.bo[state.source_buf].filetype
    vim.bo[state.buf].tabstop = vim.bo[state.source_buf].tabstop
    vim.bo[state.buf].vartabstop = vim.bo[state.source_buf].vartabstop
    vim.wo[state.win].concealcursor = vim.wo[state.source_win].concealcursor
    vim.wo[state.win].conceallevel = vim.wo[state.source_win].conceallevel
    vim.wo[state.win].signcolumn = vim.wo[state.source_win].signcolumn
    vim.wo[state.win].winhighlight = vim.wo[state.source_win].winhighlight

    local ok, namespace = pcall(vim.api.nvim_win_get_hl_ns, state.source_win)
    if ok and namespace >= 0 then
        vim.api.nvim_win_set_hl_ns(state.win, namespace)
    end
end

local function render()
    if not sidebar_is_open() or not state.source_buf or not vim.api.nvim_buf_is_valid(state.source_buf) then
        return
    end

    sync_source_appearance()
    local lines = {}
    for _, entry in ipairs(state.entries) do
        table.insert(lines, entry.text)
    end
    if #lines == 0 then
        lines = { '' }
    end

    vim.bo[state.buf].modifiable = true
    vim.api.nvim_buf_set_lines(state.buf, 0, -1, false, lines)
    vim.bo[state.buf].modifiable = false
    vim.api.nvim_buf_clear_namespace(state.buf, syntax_namespace, 0, -1)

    local highlighter = vim.treesitter.highlighter.active[state.source_buf]
    if highlighter then
        pcall(highlighter.tree.parse, highlighter.tree)
    end
    for row, entry in ipairs(state.entries) do
        copy_treesitter_highlights(entry.line - 1, row - 1, entry.text)
    end

    update_number_width()
end

---@param position { line: integer, character: integer }
---@param range SymbolSidebarEntry['range']
---@return boolean
local function range_contains(position, range)
    local starts_before = position.line > range.start.line
        or position.line == range.start.line and position.character >= range.start.character
    local ends_after = position.line < range.end_.line
        or position.line == range.end_.line and position.character < range.end_.character
    return starts_before and ends_after
end

---@param entry SymbolSidebarEntry
---@return integer
local function range_size(entry)
    return (entry.range.end_.line - entry.range.start.line) * 1000000
        + entry.range.end_.character
        - entry.range.start.character
end

---@param row integer?
local function set_active(row)
    if not sidebar_is_open() or not state.buf then
        return
    end

    state.active = row
    vim.api.nvim_buf_clear_namespace(state.buf, active_namespace, 0, -1)
    if row and state.entries[row] then
        vim.api.nvim_buf_set_extmark(state.buf, active_namespace, row - 1, 0, {
            line_hl_group = 'CursorLine',
            priority = 200,
        })
        vim.api.nvim_win_set_cursor(state.win, { row, 0 })
    end
end

local function update_active_from_source()
    if not source_is_valid() or not sidebar_is_open() then
        return
    end

    local cursor = vim.api.nvim_win_get_cursor(state.source_win)
    local position = { line = cursor[1] - 1, character = cursor[2] }
    local active

    for row, entry in ipairs(state.entries) do
        if range_contains(position, entry.range) then
            if not active
                or entry.depth > state.entries[active].depth
                or entry.depth == state.entries[active].depth
                    and range_size(entry) < range_size(state.entries[active])
            then
                active = row
            end
        end
    end

    set_active(active)
end

local function jump_from_sidebar()
    if not source_is_valid() or not sidebar_is_open() then
        return
    end

    local row = vim.api.nvim_win_get_cursor(state.win)[1]
    local entry = state.entries[row]
    if not entry then
        return
    end

    set_active(row)
    vim.api.nvim_win_set_cursor(state.source_win, { entry.line, entry.column })
end

local function refresh()
    if not sidebar_is_open() or not source_is_valid() then
        return
    end

    state.request = state.request + 1
    local request = state.request
    local clients = vim.lsp.get_clients({
        bufnr = state.source_buf,
        method = 'textDocument/documentSymbol',
    })
    local client = clients[1]

    if not client then
        state.entries = {}
        render()
        set_active(nil)
        return
    end

    state.client_id = client.id
    local params = { textDocument = vim.lsp.util.make_text_document_params(state.source_buf) }
    client:request('textDocument/documentSymbol', params, function(error, result)
        vim.schedule(function()
            if error
                or request ~= state.request
                or not sidebar_is_open()
                or client.id ~= state.client_id
            then
                return
            end

            state.entries = collect_entries(result or {}, client.offset_encoding)
            render()
            update_active_from_source()
        end)
    end, state.source_buf)
end

local function refresh_soon()
    state.refresh_pending = state.refresh_pending + 1
    local pending = state.refresh_pending
    vim.defer_fn(function()
        if pending == state.refresh_pending then
            refresh()
        end
    end, 150)
end

local function use_source_window(win)
    if not sidebar_is_open() or win == state.win or not vim.api.nvim_win_is_valid(win) then
        return
    end

    local buf = vim.api.nvim_win_get_buf(win)
    if vim.bo[buf].buftype ~= '' then
        return
    end

    local changed = buf ~= state.source_buf or win ~= state.source_win
    state.source_buf = buf
    state.source_win = win
    if changed then
        refresh()
    else
        update_active_from_source()
    end
end

local function configure_sidebar()
    vim.bo[state.buf].buflisted = false
    vim.bo[state.buf].bufhidden = 'wipe'
    vim.bo[state.buf].buftype = 'nofile'
    vim.bo[state.buf].filetype = 'symbol-sidebar'
    vim.bo[state.buf].modifiable = false
    vim.bo[state.buf].swapfile = false

    vim.wo[state.win].colorcolumn = ''
    vim.wo[state.win].cursorline = false
    vim.wo[state.win].foldcolumn = '0'
    vim.wo[state.win].list = false
    vim.wo[state.win].number = true
    vim.wo[state.win].relativenumber = false
    vim.wo[state.win].signcolumn = 'no'
    vim.wo[state.win].spell = false
    vim.wo[state.win].statuscolumn = "%!v:lua.require'symbol_sidebar'.statuscolumn()"
    vim.wo[state.win].winfixbuf = true
    vim.wo[state.win].winfixwidth = true
    vim.wo[state.win].wrap = false

    vim.keymap.set('n', 'q', M.close, { buffer = state.buf, silent = true, desc = 'Close symbol sidebar' })
    vim.keymap.set('n', '<CR>', jump_from_sidebar, {
        buffer = state.buf,
        silent = true,
        desc = 'Jump to symbol',
    })
end

function M.open()
    if sidebar_is_open() then
        vim.api.nvim_set_current_win(state.win)
        return
    end

    local source_win = vim.api.nvim_get_current_win()
    local source_buf = vim.api.nvim_get_current_buf()
    if vim.bo[source_buf].buftype ~= '' then
        return
    end

    state.opening = true
    state.source_win = source_win
    state.source_buf = source_buf
    vim.cmd('botright vertical new')
    state.win = vim.api.nvim_get_current_win()
    state.buf = vim.api.nvim_get_current_buf()
    vim.api.nvim_buf_set_name(state.buf, 'symbol-sidebar://')
    vim.api.nvim_win_set_width(state.win, resolve_width())
    configure_sidebar()
    state.opening = false
    refresh()
end

function M.close()
    local win = state.win
    local source_win = state.source_win
    state.request = state.request + 1
    state.win = nil
    state.buf = nil
    state.entries = {}
    state.active = nil

    if win and vim.api.nvim_win_is_valid(win) then
        vim.api.nvim_win_close(win, true)
    end
    if source_win and vim.api.nvim_win_is_valid(source_win) then
        vim.api.nvim_set_current_win(source_win)
    end
end

function M.toggle()
    if sidebar_is_open() then
        M.close()
    else
        M.open()
    end
end

function M.statuscolumn()
    local entry = state.entries[vim.v.lnum]
    if not entry then
        return ''
    end

    local highlight = state.active == vim.v.lnum and 'CursorLineNr' or 'LineNr'
    return '%#' .. highlight .. '#%=' .. entry.line .. ' '
end

---@param opts? table
function M.setup(opts)
    config = vim.tbl_deep_extend('force', config, opts or {})

    vim.keymap.set('n', config.keymap, M.toggle, {
        silent = true,
        desc = 'Toggle symbol sidebar',
    })

    local group = vim.api.nvim_create_augroup('SymbolSidebar', { clear = true })
    vim.api.nvim_create_autocmd({ 'BufEnter', 'WinEnter' }, {
        group = group,
        callback = function()
            if not state.opening then
                use_source_window(vim.api.nvim_get_current_win())
            end
        end,
    })
    vim.api.nvim_create_autocmd({ 'CursorMoved', 'CursorMovedI' }, {
        group = group,
        callback = function(event)
            if event.buf == state.buf then
                jump_from_sidebar()
            elseif event.buf == state.source_buf then
                update_active_from_source()
            end
        end,
    })
    vim.api.nvim_create_autocmd({ 'TextChanged', 'TextChangedI' }, {
        group = group,
        callback = function(event)
            if event.buf == state.source_buf then
                refresh_soon()
            end
        end,
    })
    vim.api.nvim_create_autocmd({ 'LspAttach', 'LspDetach' }, {
        group = group,
        callback = function(event)
            if event.buf == state.source_buf then
                refresh()
            end
        end,
    })
    vim.api.nvim_create_autocmd('VimResized', {
        group = group,
        callback = function()
            if sidebar_is_open() then
                vim.api.nvim_win_set_width(state.win, resolve_width())
            end
        end,
    })
    vim.api.nvim_create_autocmd('BufWipeout', {
        group = group,
        callback = function(event)
            if event.buf == state.buf then
                local win = state.win
                state.buf = nil
                state.win = nil
                state.entries = {}
                state.active = nil

                vim.schedule(function()
                    if win and vim.api.nvim_win_is_valid(win) then
                        pcall(vim.api.nvim_win_close, win, true)
                    end
                end)
            end
        end,
    })
end

return M
