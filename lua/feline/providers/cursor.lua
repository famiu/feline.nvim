local api = vim.api

local M = {}

local scroll_bar_blocks =  {'▁', '▂', '▃', '▄', '▅', '▆', '▇', '█'}

function M.position()
    return string.format('%3d:%-2d', unpack(api.nvim_win_get_cursor(0)))
end

function M.line_percentage()
    local curr_line = api.nvim_win_get_cursor(0)[1]
    local lines = api.nvim_buf_line_count(0)

    if curr_line == 1 then
        return "Top"
    elseif curr_line == lines then
        return "Bot"
    else
        return string.format('%2d%%%%', math.ceil(curr_line / lines * 99))
    end
end

function M.scroll_bar()
    local curr_line = api.nvim_win_get_cursor(0)[1]
    local lines = api.nvim_buf_line_count(0)

    return string.rep(scroll_bar_blocks[math.floor(curr_line / lines * 7) + 1], 2)
end

return M
