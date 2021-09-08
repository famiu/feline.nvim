local g = vim.g
local cmd = vim.cmd
local fn = vim.fn
local api = vim.api

local M = {}

-- Reset highlights
function M.reset_highlights()
    local highlights = require('feline.generator').highlights

    for hl, _ in pairs(highlights) do
        cmd('hi clear ' .. hl)
    end

    highlights = {}
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

-- Utility function to create augroups
local function create_augroup(autocmds, name)
    cmd('augroup ' .. name)
    cmd('autocmd!')

    for _, autocmd in ipairs(autocmds) do
        cmd('autocmd ' .. table.concat(autocmd, ' '))
    end

    cmd('augroup END')
end

function M.update_all_windows()
    for _, winnr in ipairs(api.nvim_list_wins()) do
        vim.wo[winnr].statusline = require('feline').statusline(winnr)
    end

    -- Reset local statusline of current window to use the global statusline for it
    vim.wo.statusline = nil
end

function M.setup(config)
    -- Check if Neovim version is 0.5 or greater
    if fn.has('nvim-0.5') ~= 1 then
        api.nvim_err_writeln('Feline is only available for Neovim versions 0.5 and above')
        return
    end

    local defaults = require('feline.defaults')
    local presets = require('feline.presets')
    local preset, components, properties

    -- Configuration options that aren't defined in a preset
    local config_opts = {
        'colors',
        'separators',
        'vi_mode_colors'
    }

    -- Parse the opts in config_opts by getting the default values and
    -- appending the custom values on top of them
    for _, opt in ipairs(config_opts) do
        local custom_val = parse_config(config, opt, 'table', {})
        M[opt] = defaults[opt]

        for k, v in pairs(custom_val) do
            M[opt][k] = v
        end
    end

    -- Deprecation warning for `default_fg` and `default_bg`
    if config.default_fg or config.default_bg then
        api.nvim_echo(
            {{
                '\nDeprecation warning:\n' ..
                'The setup options `default_fg` and `default_bg` for Feline have been ' ..
                'removed and no longer work. Please use the `fg` and `bg` values ' ..
                'of the `colors` table instead.\n',

                'WarningMsg'
            }},
            true, {}
        )
    end

    if parse_config(config, 'preset', 'string') then
        preset = presets[config.preset]
    else
        local has_devicons = pcall(require,'nvim-web-devicons')

        if has_devicons then
            preset = presets['default']
        else
            preset = presets['noicon']
        end
    end

    components = parse_config(config, 'components', 'table', preset.components)
    properties = parse_config(config, 'properties', 'table', preset.properties)

    -- Deprecation warning for old component format
    if not (components.active and components.inactive) then
        api.nvim_echo(
            {{
                '\nDeprecation warning:\n' ..
                'This format for defining Feline components has been deprecated and will soon ' ..
                'become unsupported. Please check the docs and switch your statusline ' ..
                'configuration to the new format as soon as possible.\n',

                'WarningMsg'
            }},
            true, {}
        )
    end

    M.components = components
    M.properties = properties

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

function M.statusline(winnr)
    winnr = winnr or vim.api.nvim_get_current_win()
    return require('feline.generator').generate_statusline(winnr)
end

return M
