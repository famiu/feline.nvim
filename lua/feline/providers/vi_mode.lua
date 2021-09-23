local api = vim.api

local M = {}

local mode_alias = {
    ['n'] = 'NORMAL',
    ['no'] = 'OP',
    ['nov'] = 'OP',
    ['noV'] = 'OP',
    ['no'] = 'OP',
    ['niI'] = 'NORMAL',
    ['niR'] = 'NORMAL',
    ['niV'] = 'NORMAL',
    ['v'] = 'VISUAL',
    ['V'] = 'LINES',
    [''] = 'BLOCK',
    ['s'] = 'SELECT',
    ['S'] = 'SELECT',
    [''] = 'BLOCK',
    ['i'] = 'INSERT',
    ['ic'] = 'INSERT',
    ['ix'] = 'INSERT',
    ['R'] = 'REPLACE',
    ['Rc'] = 'REPLACE',
    ['Rv'] = 'V-REPLACE',
    ['Rx'] = 'REPLACE',
    ['c'] = 'COMMAND',
    ['cv'] = 'COMMAND',
    ['ce'] = 'COMMAND',
    ['r'] = 'ENTER',
    ['rm'] = 'MORE',
    ['r?'] = 'CONFIRM',
    ['!'] = 'SHELL',
    ['t'] = 'TERM',
    ['null'] = 'NONE',
}

-- Functions for statusline
function M.get_vim_mode()
    local mode = api.nvim_get_mode().mode
    return mode_alias[mode]
end

function M.get_mode_color()
    return require('feline').vi_mode_colors[M.get_vim_mode()]
end

-- String to title case
local function title_case(str)
    return string.gsub(string.lower(str), '%a', string.upper, 1)
end

function M.get_mode_highlight_name()
    return 'StatusComponentVim' .. title_case(M.get_vim_mode())
end

function M.vi_mode(_, component)
    if component.icon == '' then
        return M.get_vim_mode()
    elseif component.icon == nil then
        return ''
    end
end

return M
