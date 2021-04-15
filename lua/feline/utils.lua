local M = {}
local cmd = vim.cmd

-- String to title case
function M.title_case(str)
    return string.gsub(string.lower(str), '%a', string.upper, 1)
end

-- Highlight function
function M.add_component_highlight(name, fg, bg, style)
    local hlname = 'StatusComponent' .. name

    if vim.fn.hlexists(hlname) ~= 0 then
        return hlname
    else
        cmd(string.format('highlight %s gui=%s guifg=%s guibg=%s', hlname, style, fg, bg))
        return hlname
    end
end

-- Create augroup
function M.create_augroup(autocmds, name)
    cmd('augroup ' .. name)
    cmd('autocmd!')

    for _, autocmd in ipairs(autocmds) do
        cmd('autocmd ' .. table.concat(autocmd, ' '))
    end

    cmd('augroup END')
end

return M
