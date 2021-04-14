local M = {}
local cmd = vim.cmd

-- Highlight function
function M.add_component_highlight(name, fg, bg, style)
    local hlname = 'StatusComponent' .. name
    cmd(string.format('highlight %s gui=%s guifg=%s guibg=%s', hlname, style, fg, bg))

    return hlname
end

return M
