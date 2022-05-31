local api = vim.api

local M = {}

local scroll_bar_blocks = { '▁', '▂', '▃', '▄', '▅', '▆', '▇', '█' }

function M.position(_, opts)
    local row, col = unpack(api.nvim_win_get_cursor(0))

    local line = api.nvim_get_current_line()
    -- Get the text before the cursor in the current line
    local before_cursor = line:sub(1, col)

    -- Replace tabs with the equivalent amount of spaces according to the value of 'tabstop'
    before_cursor = before_cursor:gsub('\t', string.rep(' ', vim.bo.tabstop))

    -- Turn col from byteindex to column number and make it start from 1
    col = vim.str_utfindex(before_cursor) + 1

    if opts.padding then
        return string.format('%3d:%-2d', row, col)
    else
        return string.format('%d:%d', row, col)
    end
end

function M.line_percentage()
    local curr_line = api.nvim_win_get_cursor(0)[1]
    local lines = api.nvim_buf_line_count(0)

    if curr_line == 1 then
        return 'Top'
    elseif curr_line == lines then
        return 'Bot'
    else
        return string.format('%2d%%%%', math.ceil(curr_line / lines * 99))
    end
end

function M.scroll_bar(_, opts)
    local curr_line = api.nvim_win_get_cursor(0)[1]
    local lines = api.nvim_buf_line_count(0)

    if opts.reverse then
        return string.rep(scroll_bar_blocks[8 - math.floor(curr_line / lines * 7)], 2)
    else
        return string.rep(scroll_bar_blocks[math.floor(curr_line / lines * 7) + 1], 2)
    end
end

return M
