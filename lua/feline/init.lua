local g = vim.g
local cmd = vim.cmd
local fn = vim.fn
local api = vim.api
local gen = require('feline.generator')

local M = {}

M.reset_highlights = gen.reset_highlights

function M.update_all_windows()
    for _, winid in ipairs(api.nvim_tabpage_list_wins(0)) do
        if api.nvim_win_get_config(winid).relative == '' then
            vim.wo[winid].statusline = api.nvim_win_call(winid,
                function()
                    return require('feline').statusline(winid)
                end
            )
        end
    end

    -- Reset local statusline of current window to use the global statusline for it
    vim.wo.statusline = nil
end

local function parse_config(config_dict, config_name, expected_type, default_value)
    if config_dict and config_dict[config_name] then
        if type(config_dict[config_name]) == expected_type then
            return config_dict[config_name]
        else
            print(
                string.format("Feline: Expected '%s' for config option '%s', got '%s'"),
                expected_type, config_name, type(config_dict[config_name])
            )
        end
    elseif default_value then
        return default_value
    else
        return nil
    end
end

-- Create augroup
local function create_augroup(autocmds, name)
    cmd('augroup ' .. name)
    cmd('autocmd!')

    for _, autocmd in ipairs(autocmds) do
        cmd('autocmd ' .. table.concat(autocmd, ' '))
    end

    cmd('augroup END')
end

function M.setup(config)
    -- Check if Neovim version is 0.5 or greater
    if fn.has('nvim-0.5') ~= 1 then
        api.nvim_err_writeln("Feline is only available for Neovim versions 0.5 and above")
        return
    end

    local colors = require('feline.defaults').colors
    local separators = require('feline.defaults').separators
    local vi_mode = require('feline.providers.vi_mode')
    local presets = require('feline.presets')
    local preset, components, properties
    local custom_colors, custom_separators, vi_mode_colors

    if parse_config(config, "preset", "string") then
        preset = presets[config.preset]
    else
        local has_devicons = pcall(require,'nvim-web-devicons')
        if has_devicons then
            preset = presets["default"]
        else
            preset = presets["noicon"]
        end
    end

    custom_colors = parse_config(config, "colors", "table", {})
    custom_separators = parse_config(config, "separators", "table", {})

    for color, hex in pairs(custom_colors) do colors[color] = hex end
    for name, str in pairs(custom_separators) do separators[name] = str end

    colors.fg = parse_config(config, "default_fg", "string", colors.fg)
    colors.bg = parse_config(config, "default_bg", "string", colors.bg)
    vi_mode_colors = parse_config(config, "vi_mode_colors", "table", {})
    components = parse_config(config, "components", "table", preset.components)
    properties = parse_config(config, "properties", "table", preset.properties)

    for k,v in pairs(vi_mode_colors) do
        if colors[v] then v = colors[v] end
        vi_mode.mode_colors[k] = v
    end

    -- Deprecation warning for old component format
    if not (components.active and components.inactive) then
        api.nvim_echo(
            {{
                "\nDeprecation warning:\n" ..
                "This format for defining Feline components has been deprecated and will soon " ..
                "become unsupported. Please check the docs and switch your statusline " ..
                "configuration to the new format as soon as possible.\n",

                "WarningMsg"
            }},
            true, {}
        )
    end

    gen.components = components
    gen.properties = properties

    -- Ensures custom quickfix statusline isn't loaded
    g.qf_disable_statusline = true

    vim.o.statusline = '%!v:lua.require\'feline\'.statusline()'

    create_augroup({
        {
            'WinEnter,BufEnter,WinLeave,BufLeave,SessionLoadPost,FileChangedShellPost',
            '*',
            'lua require("feline").update_all_windows()'
        },
        {
            'SessionLoadPost,ColorScheme',
            '*',
            'lua require("feline").reset_highlights()'
        }
    }, 'feline')
end

function M.statusline(winid)
    winid = winid or fn.win_getid()
    if g.statusline_winid == winid then
        return gen.generate_statusline(true)
    else
        return gen.generate_statusline(false)
    end
end

return M
