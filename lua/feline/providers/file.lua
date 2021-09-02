local fn = vim.fn
local o = vim.o
local bo = vim.bo

local M = {}

-- Get the names of all current listed buffers
local function get_current_filenames()
    local listed_buffers = vim.tbl_filter(
        function(buffer)
            return buffer.listed == 1
        end,
        fn.getbufinfo()
    )

    return vim.tbl_map(function(buffer) return buffer.name end, listed_buffers)
end

-- Get unique name for the current buffer
local function get_unique_filename(filename)
    local filenames = vim.tbl_filter(
        function(filename_other)
            return filename_other ~= filename
        end,
        get_current_filenames()
    )

    filename = string.reverse(filename)

    local index

    if next(filenames) then
        filenames = vim.tbl_map(string.reverse, filenames)

        index = math.max(unpack(vim.tbl_map(
            function(filename_other)
                for i = 1, #filename do
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

    while index <= #filename do
        if filename:sub(index, index) == "/" then
            index = index - 1
            break
        end

        index = index + 1
    end

    return string.reverse(string.sub(filename, 1, index))

end

function M.file_info(component)
    local filename

    component.type = component.type or 'base-only'

    if component.type == 'full-path' then
        filename = '%F'
    elseif component.type == 'short-path' then
        filename = fn.pathshorten(fn.expand('%:p'))
    elseif component.type == 'base-only' then
        filename = '%t'
    elseif component.type == 'relative' then
        filename = '%f'
    elseif component.type == 'relative-short' then
        filename = fn.pathshorten(fn.fnamemodify(fn.expand("%"), ":~:."))
    elseif component.type == 'unique' then
        filename = get_unique_filename(fn.expand('%:p'))
    elseif component.type == 'unique-short' then
        filename = get_unique_filename(fn.pathshorten(fn.expand('%:p')))
    else
        filename = fn.expand('%:t')
    end

    local extension = fn.expand('%:e')
    local modified_str

    local icon = component.icon
    if not icon then
        local ic, hl_group = require("nvim-web-devicons").get_icon(filename, extension, { default = true })
        local colored_icon
        
        if component.colored_icon == nil then
            colored_icon = true
        else
            colored_icon = component.colored_icon
        end
        
        icon = { str = ic }

        if colored_icon then
            local fg = vim.api.nvim_get_hl_by_name(hl_group, true)['foreground']
            if fg then
                icon["hl"] = { fg = string.format('#%06x', fg) }
            end
        end
    end

    if filename == '' then filename = 'unnamed' end

    if bo.modified then
        local modified_icon = component.file_modified_icon or '●'
        modified_str = modified_icon .. ' '
    else
        modified_str = ''
    end

    return ' ' .. filename .. ' ' .. modified_str, icon
end

function M.file_size()
    local suffix = {'b', 'k', 'M', 'G', 'T', 'P', 'E'}
    local index = 1

    local fsize = fn.getfsize(fn.expand('%:p'))

    while fsize > 1024 and index < 7 do
        fsize = fsize / 1024
        index = index + 1
    end

    return string.format(index == 1 and '%g' or '%.2f', fsize) .. suffix[index]
end

function M.file_type()
    return bo.filetype:upper()
end

function M.file_encoding()
    local enc = (bo.fenc ~= '' and bo.fenc) or o.enc
    return enc:upper()
end

return M
