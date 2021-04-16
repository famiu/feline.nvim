local wo = vim.wo
local uv = vim.loop

local gen = require('feline.generator')
local utils = require('feline.utils')

local M = {}

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

function M.setup(config)
    local colors = require('feline.defaults').colors
    local vi_mode = require('feline.providers.vi_mode')
    local generator = require('feline.generator')
    local presets = require('feline.presets')
    local vi_mode_colors, components, properties, preset

    if parse_config(config, "preset", "string") then
        preset = presets[config.preset]
    else
        preset = presets["default"]
    end

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

    utils.create_augroup({
        {'WinEnter,BufEnter', '*', 'lua require\'feline\'.statusline()'},
        {'WinLeave,BufLeave', '*', 'lua require\'feline\'.inactive_statusline()'}
    }, 'feline')
end

local sl_timer = uv.new_timer()

local set_statusline = vim.schedule_wrap(function ()
    wo.statusline = gen.generate_statusline(true)
end)

function M.inactive_statusline()
    wo.statusline = gen.generate_statusline(false)
end
 
function M.statusline()
    sl_timer:stop()
    sl_timer:start(0, 100, set_statusline)
end

return M
