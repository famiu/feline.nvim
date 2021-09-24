local fn = vim.fn
local bo = vim.bo
local api = vim.api

local M = {}

-- Get the names of all current listed buffers
local function get_current_filenames()
    local listed_buffers = vim.tbl_filter(
        function(bufnr)
            return bo[bufnr].buflisted and api.nvim_buf_is_loaded(bufnr)
        end,
        api.nvim_list_bufs()
    )

    return vim.tbl_map(api.nvim_buf_get_name, listed_buffers)
end

-- Get unique name for the current buffer
local function get_unique_filename(filename, shorten)
    local filenames = vim.tbl_filter(
        function(filename_other)
            return filename_other ~= filename
        end,
        get_current_filenames()
    )

    if shorten then
        filename = fn.pathshorten(filename)
        filenames = vim.tbl_map(fn.pathshorten, filenames)
    end

    -- Reverse filenames in order to compare their names
    filename = string.reverse(filename)
    filenames = vim.tbl_map(string.reverse, filenames)

    local index

    -- For every other filename, compare it with the name of the current file char-by-char to
    -- find the minimum index `i` where the i-th character is different for the two filenames
    -- After doing it for every filename, get the maximum value of `i`
    if next(filenames) then
        index = math.max(unpack(vim.tbl_map(
            function(filename_other)
                for i = 1, #filename do
                    -- Compare i-th character of both names until they aren't equal
                    if filename:sub(i, i) ~= filename_other:sub(i, i) then
                        return i
                    end
                end
                return 1
            end,
            filenames
        )))
    else
        index = 1
    end

    -- Iterate backwards (since filename is reversed) until a "/" is found
    -- in order to show a valid file path
    while index <= #filename do
        if filename:sub(index, index) == "/" then
            index = index - 1
            break
        end

        index = index + 1
    end

    return string.reverse(string.sub(filename, 1, index))
end

function M.file_info(winid, component, opts)
    local filename = api.nvim_buf_get_name(api.nvim_win_get_buf(winid))
    local type = opts.type or 'base-only'

    if type == 'short-path' then
        filename = fn.pathshorten(filename)
    elseif type == 'base-only' then
        filename = fn.fnamemodify(filename, ':t')
    elseif type == 'relative' then
        filename = fn.fnamemodify(filename, ":~:.")
    elseif type == 'relative-short' then
        filename = fn.pathshorten(fn.fnamemodify(filename, ":~:."))
    elseif type == 'unique' then
        filename = get_unique_filename(filename)
    elseif type == 'unique-short' then
        filename = get_unique_filename(filename, true)
    elseif type ~= 'full-path' then
        filename = fn.fnamemodify(filename, ':t')
    end

    local extension = fn.fnamemodify(filename, ':e')
    local readonly_str, modified_str

    local icon

    -- Avoid loading nvim-web-devicons if an icon is provided already
    if not component.icon then
        local icon_str, icon_hlname = require("nvim-web-devicons").get_icon(
            filename, extension, { default = true }
        )

        icon = { str = icon_str }

        if opts.colored_icon == nil or opts.colored_icon then
            local fg = api.nvim_get_hl_by_name(icon_hlname, true).foreground

            if fg then
                icon.hl = { fg = string.format('#%06x', fg) }
            end
        end
    end

    if filename == '' then filename = 'unnamed' end

    local bufnr = api.nvim_win_get_buf(winid)

    if bo[bufnr].readonly then
        readonly_str = opts.file_readonly_icon or '🔒'
    else
        readonly_str = ''
    end

    if bo[bufnr].modified then
        modified_str = opts.file_modified_icon or '●'

        if modified_str ~= '' then modified_str = modified_str .. ' ' end
    else
        modified_str = ''
    end

    return ' ' .. readonly_str .. filename .. ' ' .. modified_str, icon
end

function M.file_size(winid)
    local suffix = {'b', 'k', 'M', 'G', 'T', 'P', 'E'}
    local index = 1

    local fsize = fn.getfsize(api.nvim_buf_get_name(api.nvim_win_get_buf(winid)))

    if fsize < 0 then fsize = 0 end

    while fsize > 1024 and index < 7 do
        fsize = fsize / 1024
        index = index + 1
    end

    return string.format(index == 1 and '%g' or '%.2f', fsize) .. suffix[index]
end

function M.file_type(winid)
    return bo[api.nvim_win_get_buf(winid)].filetype:upper()
end

function M.file_encoding(winid)
    local bufnr = api.nvim_win_get_buf(winid)
    local enc = (bo[bufnr].fenc ~= '' and bo[bufnr].fenc) or vim.o.enc
    return enc:upper()
end

return M
