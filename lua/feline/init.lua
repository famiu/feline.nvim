local g = vim.g
local opt = vim.opt
local fn = vim.fn
local api = vim.api
local cmd = api.nvim_command

local utils = require('feline.utils')
local gen = utils.lazy_require('feline.generator')

local M = {}

-- Parse configuration option with name config_name from config_dict and match its type
-- Return a default value (if provided one) in case the configuration option doesn't exist
local function parse_config(config_dict, defaults)
    local parsed_config = {}

    -- Iterate through every possible configuration options, also checking their type to ensure the
    -- validity of the configuration and also using the defaults if a custom configuration is not
    -- provided
    for config_name, config_info in pairs(defaults) do
        if config_dict[config_name] == nil then
            parsed_config[config_name] = config_info.default_value
        elseif type(config_dict[config_name]) ~= config_info.type then
            api.nvim_err_writeln(string.format(
                "Feline: expected type '%s' for config option '%s', got '%s'",
                config_info.type,
                config_name,
                type(config_dict[config_name])
            ))

            parsed_config[config_name] = config_info.default_value
        elseif config_info.update_default then
            local config_value = {}

            for k, v in pairs(config_info.default_value) do
                config_value[k] = v
            end

            for k, v in pairs(config_dict[config_name]) do
                config_value[k] = v
            end

            parsed_config[config_name] = config_value
        else
            parsed_config[config_name] = config_dict[config_name]
        end
    end

    return parsed_config
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

    -- Check if termguicolors is enabled
    if not opt.termguicolors:get() then
        api.nvim_err_writeln(
            'Feline needs \'termguicolors\' to be enabled to work properly\n' ..
            'Please do `:help \'termguicolors\'` in Neovim for more information'
        )
        return
    end

    config = parse_config(config, require('feline.defaults'))

    M.colors = config.colors
    M.separators = config.separators
    M.vi_mode_colors = config.vi_mode_colors
    M.force_inactive = config.force_inactive
    M.disable = config.disable
    M.default_hl = config.default_hl

    M.providers = require('feline.providers')

    -- Register custom providers
    for k, v in pairs(config.custom_providers) do
        M.providers[k] = v
    end

    -- If components table is provided, use it, else use a preset
    if config.components then
        M.components = config.components
    else
        local preset = config.preset
        local presets = require('feline.presets')

        -- If a valid preset isn't provided, then use the default preset if nvim-web-devicons
        -- exists, else use the noicons preset
        if not (preset and presets[preset]) then
            if pcall(require, 'nvim-web-devicons') then
                preset = 'default'
            else
                preset = 'noicon'
            end
        end

        M.components = presets[preset]
    end

    -- Ensures custom quickfix statusline isn't loaded
    g.qf_disable_statusline = true

    -- Set the value of the statusline option to Feline's statusline generation function
    opt.statusline = '%{%v:lua.require\'feline\'.statusline()%}'

    -- Autocommand to reset highlights according to the `highlight_reset_triggers` configuration
    if next(config.highlight_reset_triggers) then
        utils.create_augroup({
            {
                table.concat(config.highlight_reset_triggers, ','),
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
