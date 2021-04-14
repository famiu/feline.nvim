local fn = vim.fn
local o = vim.o
local bo = vim.bo

local M = {}

function M.file_info(component)
    local filename = fn.expand('%:t')
    local extension = fn.expand('%:e')
    local icon
    local modified

    if component and component.icon then
        icon = component.icon
    else
        icon = require'nvim-web-devicons'.get_icon(filename, extension, { default = true })
    end

    if filename == '' then filename = 'unnamed' end

    if bo.modified then
        modified = '●' .. ' '
    else
        modified = ''
    end

    return icon .. ' ' .. filename .. ' ' .. modified
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
    return bo[vim.api.nvim_get_current_buf()].filetype:upper()
end

function M.file_encoding()
    local enc = (bo.fenc ~= '' and bo.fenc) or o.enc
    return enc:upper()
end

return M
