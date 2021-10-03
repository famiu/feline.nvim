local g = vim.g
local fn = vim.fn
local api = vim.api
local cmd = api.nvim_command

local utils = require('feline.utils')
local gen = utils.lazy_require('feline.generator')

local M = {}

-- Parse configuration option with name config_name from config_dict and match its type
-- Return a default value (if provided one) in case the configuration option doesn't exist
local function parse_config(config_dict, config_name, expected_type, default_value)
    if config_dict and config_dict[config_name] then
        if type(config_dict[config_name]) == expected_type then
            return config_dict[config_name]
        else
            api.nvim_err_writeln(string.format(
                "Feline: Expected '%s' for config option '%s', got '%s'",
                expected_type,
                config_name,
                type(config_dict[config_name])
            ))
        end
    else
        return default_value
    end
end

-- Clear all highlights created by Feline and remove them from cache
function M.reset_highlights()
    for hl, _ in pairs(gen.highlights) do
        cmd('highlight clear ' .. hl)
    end

    gen.highlights = {}
end

-- Setup Feline using the provided configuration options
function M.setup(config)
    -- Check if Neovim version is 0.5 or greater
    if fn.has('nvim-0.5') ~= 1 then
        api.nvim_err_writeln('Feline is only available for Neovim versions 0.5 and above')
        return
    end

    local defaults = require('feline.defaults')

    -- Value presets
    local value_presets = {
        'colors',
        'separators',
        'vi_mode_colors',
    }

    -- Parse the opts in config_opts by getting the default values and
    -- appending the custom values on top of them
    for _, opt in ipairs(value_presets) do
        local custom_val = parse_config(config, opt, 'table', {})
        M[opt] = defaults[opt]

        for k, v in pairs(custom_val) do
            M[opt][k] = v
        end
    end

    M.force_inactive = parse_config(config, 'force_inactive', 'table', defaults.force_inactive)
    M.disable = parse_config(config, 'disable', 'table', defaults.disable)

    M.providers = require('feline.providers')

    for k, v in pairs(parse_config(config, 'custom_providers', 'table', {})) do
        M.providers[k] = v
    end

    local components = parse_config(config, 'components', 'table')

    if not components then
        local presets = require('feline.presets')

        if parse_config(config, 'preset', 'string') and presets[config.preset] then
            components = presets[config.preset]
        else
            local has_devicons = pcall(require,'nvim-web-devicons')

            if has_devicons then
                components = presets['default']
            else
                components = presets['noicon']
            end
        end
    end

    M.components = components
    M.default_hl = parse_config(config, 'default_hl', 'table', {})

    -- Ensures custom quickfix statusline isn't loaded
    g.qf_disable_statusline = true

    vim.o.statusline = '%{%v:lua.require\'feline\'.statusline()%}'

    local highlight_reset_triggers = parse_config(
        config,
        'highlight_reset_triggers',
        'table',
        defaults.highlight_reset_triggers
    )

    -- Autocommand to reset highlights according to the `highlight_reset_triggers` configuration
    if next(highlight_reset_triggers) then
        utils.create_augroup({
            {
                table.concat(highlight_reset_triggers, ','),
                '*',
                'lua require("feline").reset_highlights()'
            }
        }, 'feline')
    end
end

function M.statusline()
    return gen.generate_statusline(api.nvim_get_current_win() == tonumber(g.actual_curwin))
end

return M
