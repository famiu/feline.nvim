local fn = vim.fn

local M = {}

function M.position()
    return string.format('%3d:%-2d', fn.line('.'), fn.col('.'))
end

function M.line_percentage()
    local curr_line = fn.line('.')
    local lines = fn.line('$')

    if curr_line == 1 then
        return "Top"
    elseif curr_line == lines then
        return "Bot"
    else
        return string.format('%2d%%%%', fn.round(curr_line / lines * 100))
    end
end

function M.scroll_bar()
    local blocks =  {'▁', '▂', '▃', '▄', '▅', '▆', '▇', '█'}
    local width = 2

    local curr_line = fn.line('.')
    local lines = fn.line('$')

    local index = fn.floor(curr_line / lines * (#blocks - 1)) + 1

    return string.rep(blocks[index], width)
end

return M
