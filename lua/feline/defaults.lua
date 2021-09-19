local M = {}

-- Theme for statusline
M.colors = {
    bg = '#1F1F23',
    black = '#1B1B1B',
    skyblue = '#50B0F0',
    cyan = '#009090',
    fg = '#D0D0D0',
    green = '#60A040',
    oceanblue = '#0066cc',
    magenta = '#C26BDB',
    orange = '#FF9000',
    red = '#D10000',
    violet = '#9E93E8',
    white = '#FFFFFF',
    yellow = '#E1E120'
}

M.separators = {
    vertical_bar = '┃',
    vertical_bar_thin = '│',
    left = '',
    right = '',
    block = '█',
    left_filled = '',
    right_filled = '',
    slant_left = '',
    slant_left_thin = '',
    slant_right = '',
    slant_right_thin = '',
    slant_left_2 = '',
    slant_left_2_thin = '',
    slant_right_2 = '',
    slant_right_2_thin = '',
    left_rounded = '',
    left_rounded_thin = '',
    right_rounded = '',
    right_rounded_thin = '',
    circle = '●'
}

M.vi_mode_colors = {
    ['NORMAL'] = 'green',
    ['OP'] = 'green',
    ['INSERT'] = 'red',
    ['VISUAL'] = 'skyblue',
    ['LINES'] = 'skyblue',
    ['BLOCK'] = 'skyblue',
    ['REPLACE'] = 'violet',
    ['V-REPLACE'] = 'violet',
    ['ENTER'] = 'cyan',
    ['MORE'] = 'cyan',
    ['SELECT'] = 'orange',
    ['COMMAND'] = 'green',
    ['SHELL'] = 'green',
    ['TERM'] = 'green',
    ['NONE'] = 'yellow'
}

M.force_inactive = {
    filetypes = {
        '^NvimTree$',
        '^packer$',
        '^startify$',
        '^fugitive$',
        '^fugitiveblame$',
        '^qf$',
        '^help$'
    },
    buftypes = {
        '^terminal$'
    },
    bufnames = {}
}

M.disable = {}

M.update_triggers = {
    'VimEnter',
    'WinEnter',
    'WinClosed',
    'FileChangedShellPost'
}

return M
