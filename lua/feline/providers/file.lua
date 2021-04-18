local fn = vim.fn
local o = vim.o
local bo = vim.bo

local M = {}

function M.file_info(component)
    local filename = fn.expand('%:t')
    local extension = fn.expand('%:e')
    local modified_str

    local icon = component.icon or
        require'nvim-web-devicons'.get_icon(filename, extension, { default = true })

    if filename == '' then filename = 'unnamed' end

    if bo.modified then
        local modified_icon = component.file_modified_icon or '●'
        modified_str = modified_icon .. ' '
    else
        modified_str = ''
    end

    return icon .. ' ' .. filename .. ' ' .. modified_str
end

function M.file_size()
    local suffix = {'b', 'k', 'M', 'G', 'T', 'P', 'E'}
    local index = 1

    local fsize = fn.getfsize(fn.expand('%:p'))

    while fsize > 1024 and index < 7 do
        fsize = fsize / 1024
        index = index + 1
    end

    return string.format('%.2f', fsize) .. suffix[index]
end

function M.file_type()
    return bo.filetype:upper()
end

function M.file_encoding()
    local enc = (bo.fenc ~= '' and bo.fenc) or o.enc
    return enc:upper()
end

return M
