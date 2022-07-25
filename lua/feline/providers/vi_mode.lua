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
    ['vs'] = 'VISUAL',
    ['V'] = 'LINES',
    ['Vs'] = 'LINES',
    [''] = 'BLOCK',
    ['s'] = 'BLOCK',
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
    ['nt'] = 'TERM',
    ['null'] = 'NONE',
}

-- Maximum possible length for a mode name (used for padding)
local mode_name_max_length = math.max(unpack(vim.tbl_map(function(str)
    return #str
end, vim.tbl_values(mode_alias))))

-- Functions for statusline
function M.get_vim_mode()
    return mode_alias[api.nvim_get_mode().mode]
end

function M.get_mode_color()
    return require('feline').vi_mode_colors[M.get_vim_mode()]
end

function M.get_mode_highlight_name()
    return 'StatusComponentVim'
        .. string.gsub(string.lower(M.get_vim_mode()), '%a', string.upper, 1)
end

function M.vi_mode(component, opts)
    local str

    if opts.show_mode_name == nil then
        opts.show_mode_name = (component.icon == '')
    end

    if opts.show_mode_name then
        str = M.get_vim_mode()

        if opts.padding then
            local padding_length = mode_name_max_length - #str

            if opts.padding == 'left' then
                str = string.rep(' ', padding_length) .. str
            elseif opts.padding == 'right' then
                str = str .. string.rep(' ', padding_length)
            elseif opts.padding == 'center' then
                str = string.rep(' ', math.floor(padding_length / 2))
                    .. str
                    .. string.rep(' ', math.ceil(padding_length / 2))
            end
        end
    else
        str = ''
    end

    return str, { str = ' ', always_visible = true }
end

return M
