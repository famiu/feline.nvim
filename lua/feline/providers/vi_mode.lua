local fn = vim.fn
local colors = require('feline.defaults').colors

local M = {}

local mode_alias = {
    n = 'NORMAL',
    no = 'OP',
    nov = 'OP',
    noV = 'OP',
    ['no'] = 'OP',
    niI = 'NORMAL',
    niR = 'NORMAL',
    niV = 'NORMAL',
    v = 'VISUAL',
    V = 'VISUAL',
    [''] = 'BLOCK',
    s = 'SELECT',
    S = 'SELECT',
    [''] = 'BLOCK',
    i = 'INSERT',
    ic = 'INSERT',
    ix = 'INSERT',
    R = 'REPLACE',
    Rc = 'REPLACE',
    Rv = 'V-REPLACE',
    Rx = 'REPLACE',
    c = 'COMMAND',
    cv = 'COMMAND',
    ce = 'COMMAND',
    r = 'ENTER',
    rm = 'MORE',
    ['r?'] = 'CONFIRM',
    ['!'] = 'SHELL',
    t = 'TERM',
    ['null'] = 'NONE',
}

M.mode_colors = {
    NORMAL = colors.green,
    OP = colors.green,
    INSERT = colors.red,
    VISUAL = colors.skyblue,
    BLOCK = colors.skyblue,
    REPLACE = colors.violet,
    ['V-REPLACE'] = colors.violet,
    ENTER = colors.cyan,
    MORE = colors.cyan,
    SELECT = colors.orange,
    COMMAND = colors.green,
    SHELL = colors.green,
    TERM = colors.green,
    NONE = colors.yellow
}

-- String to title case
local title_case = function(str)
    return string.gsub(string.lower(str), '%a', string.upper, 1)
end

-- Functions for statusline
function M.get_vim_mode()
    return mode_alias[fn.mode()]
end

function M.get_mode_color()
    return M.mode_colors[M.get_vim_mode()]
end

function M.get_mode_highlight_name()
    return 'StatusComponentVim' .. title_case(M.get_vim_mode())
end

function M.vi_mode()
    return ''
end

return M
