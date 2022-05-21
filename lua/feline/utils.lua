-- Utility functions used across Feline
local api = vim.api

local M = {}

-- Utility function to create augroups
function M.create_augroup(autocmds, name, no_clear)
    if no_clear == nil then
        no_clear = true
    end

    local group = api.nvim_create_augroup(name, { clear = not no_clear })

    for _, autocmd in ipairs(autocmds) do
        autocmd.opts.group = group
        api.nvim_create_autocmd(autocmd.event, autocmd.opts)
    end
end

-- Lazy require function
-- Only actually `require()`s a module when it gets used
function M.lazy_require(module)
    local mt = {}

    mt.__index = function(_, key)
        if not mt._module then
            mt._module = require(module)
        end

        return mt._module[key]
    end

    mt.__newindex = function(_, key, val)
        if not mt._module then
            mt._module = require(module)
        end

        mt._module[key] = val
    end

    mt.__metatable = false

    return setmetatable({}, mt)
end

-- Parse configuration option with name config_name from config_dict and match its type
-- Return a default value (if provided one) in case the configuration option doesn't exist
function M.parse_config(config_dict, defaults)
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

return M
