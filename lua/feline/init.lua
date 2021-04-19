local g = vim.g
local cmd = vim.cmd
local fn = vim.fn
local gen = require('feline.generator')

local M = {}

M.reset_highlights = gen.reset_highlights

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
    local colors = require('feline.defaults').colors
    local separators = require('feline.defaults').separators
    local vi_mode = require('feline.providers.vi_mode')
    local generator = require('feline.generator')
    local presets = require('feline.presets')
    local preset, components, properties
    local custom_colors, custom_separators, vi_mode_colors

    if parse_config(config, "preset", "string") then
        preset = presets[config.preset]
    else
        preset = presets["default"]
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

    generator.components = components
    generator.properties = properties

    vim.o.statusline = '%!v:lua.require\'feline\'.statusline()'

    create_augroup({
        {'WinEnter,BufEnter', '*', 'set statusline<'},
        {'WinLeave,BufLeave', '*', 'lua vim.wo.statusline=require\'feline\'.statusline()'}
    }, 'feline')
end

function M.statusline()
    if g.statusline_winid == fn.win_getid() then
        return gen.generate_statusline(true)
    else
        return gen.generate_statusline(false)
    end
end

return M
