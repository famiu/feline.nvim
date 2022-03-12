local g = vim.g
local opt = vim.opt
local fn = vim.fn
local api = vim.api
local cmd = api.nvim_command

local presets = require('feline.presets')
local themes = require('feline.themes')
local utils = require('feline.utils')
local gen = utils.lazy_require('feline.generator')

local M = {}

-- Parse configuration option with name config_name from config_dict and match its type
-- Return a default value (if provided one) in case the configuration option doesn't exist
local function parse_config(config_dict, defaults)
    if not config_dict then
        config_dict = {}
    end

    local parsed_config = {}

    local function config_has_correct_type(config_name, possible_types)
        local config_type = type(config_dict[config_name])

        -- If there's only one possible type (which means that `possible_types is a string`)
        -- just check for type equality and return the result
        if type(possible_types) == 'string' then
            return config_type == possible_types
        end

        -- Otherwise, iterate through every possible type until a match is found
        for _, v in ipairs(possible_types) do
            if config_type == v then
                return true
            end
        end

        return false
    end

    -- Iterate through every possible configuration options, also checking their type to ensure the
    -- validity of the configuration and also using the defaults if a custom configuration is not
    -- provided
    for config_name, config_info in pairs(defaults) do
        if config_dict[config_name] == nil then
            parsed_config[config_name] = config_info.default_value
        elseif not config_has_correct_type(config_name, config_info.type) then
            api.nvim_err_writeln(
                string.format(
                    "Feline: expected type '%s' for config option '%s', got '%s'",
                    config_info.type,
                    config_name,
                    type(config_dict[config_name])
                )
            )

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

-- Add a new preset for Feline (useful for plugins which intend to extend Feline)
function M.add_preset(name, value)
    presets[name] = value
end

-- Use a preset
function M.use_preset(name)
    if presets[name] then
        M.components = presets[name]
    else
        api.nvim_err_writeln(string.format("Preset '%s' not found!", name))
    end
end

-- Add a Feline color theme
function M.add_theme(name, value)
    themes[name] = value
end

-- Use a theme (can be either a string containing theme name or a table containing theme colors)
function M.use_theme(name_or_tbl)
    local theme_colors

    if type(name_or_tbl) == 'string' then
        if not themes[name_or_tbl] then
            api.nvim_err_writeln(string.format("Theme '%s' not found!", name_or_tbl))
            return
        end

        theme_colors = themes[name_or_tbl]
    else
        theme_colors = name_or_tbl
    end

    local colors = {}

    -- To make sure Feline falls back to default theme for missing colors, first iterate through the
    -- default colors and put their values in the colors table, and then iterate through the
    -- theme colors to update the default values
    for k, v in pairs(themes.default) do
        colors[k] = v
    end

    for k, v in pairs(theme_colors) do
        colors[k] = v
    end

    M.colors = colors
    M.reset_highlights()
end

-- Check if component with `name` in the statusline of window `winid` is truncated or hidden
function M.is_component_truncated(winid, name)
    if gen.component_truncated[winid][name] == nil then
        api.nvim_err_writeln(string.format("Component with name '%s' not found", name))
        return
    end

    return gen.component_truncated[winid][name]
end

-- Check if component with `name` in the statusline of window `winid` is hidden
function M.is_component_hidden(winid, name)
    if gen.component_hidden[winid][name] == nil then
        api.nvim_err_writeln(string.format("Component with name '%s' not found", name))
        return
    end

    return gen.component_hidden[winid][name]
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
            "Feline needs 'termguicolors' to be enabled to work properly\n"
                .. "Please do `:help 'termguicolors'` in Neovim for more information"
        )
        return
    end

    config = parse_config(config, require('feline.defaults'))

    M.separators = config.separators
    M.vi_mode_colors = config.vi_mode_colors
    M.force_inactive = config.force_inactive
    M.disable = config.disable

    -- Unload providers in case they were loaded before to prevent custom providers from old
    -- configuration being cached
    package.loaded['feline.providers'] = nil
    M.providers = require('feline.providers')

    -- Register custom providers
    for k, v in pairs(config.custom_providers) do
        M.providers[k] = v
    end

    -- Use configured theme
    M.use_theme(config.theme)

    -- If components table is provided, use it, else use a preset
    if config.components then
        M.components = config.components
    else
        local preset = config.preset

        -- If a valid preset isn't provided, then use the default preset if nvim-web-devicons
        -- exists, else use the noicon preset
        if not (preset and presets[preset]) then
            if pcall(require, 'nvim-web-devicons') then
                preset = 'default'
            else
                preset = 'noicon'
            end
        end

        M.use_preset(preset)
    end

    M.conditional_components = config.conditional_components

    -- Ensures custom quickfix statusline isn't loaded
    g.qf_disable_statusline = true

    -- Clear statusline generator state
    gen.clear_state()

    -- Set the value of the statusline option to Feline's statusline generation function
    opt.statusline = "%{%v:lua.require'feline'.statusline()%}"

    -- Autocommand to reset highlights according to the `highlight_reset_triggers` configuration
    if next(config.highlight_reset_triggers) then
        utils.create_augroup({
            {
                table.concat(config.highlight_reset_triggers, ','),
                '*',
                'lua require("feline").reset_highlights()',
            },
        }, 'feline')
    end
end

function M.statusline()
    return gen.generate_statusline(api.nvim_get_current_win() == tonumber(g.actual_curwin))
end

return M
