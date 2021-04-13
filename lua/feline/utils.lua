local M = {}
local cmd = vim.cmd

-- Highlight function
function M.add_component_highlight(name, fg, bg, style)
    local hlname = 'StatusComponent' .. name
    cmd(
        'highlight ' .. hlname ..
        ' gui=' .. style ..
        ' guifg=' .. fg ..
        ' guibg=' .. bg
    )

    return hlname
end

function M.add_highlights(highlights)
    local hlnames = {}

    for _,v in ipairs(highlights) do
        table.insert(hlnames, M.add_component_highlight(v[0], v[1], v[2], v[3]))
    end

    return hlnames
end

return M
