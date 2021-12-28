-- Use lazy_require to only load the preset that's are being used
local api = vim.api
local lazy_require = require('feline.utils').lazy_require

local default_presets = {
    default = lazy_require('feline.presets.default'),
    noicon = lazy_require('feline.presets.noicon'),
}

local custom_presets = {}

local presets_mt = {
    __index = function(_, key)
        if default_presets[key] then
            return default_presets[key]
        elseif custom_presets[key] then
            return custom_presets[key]
        end
    end,
    __newindex = function(_, key, val)
        if default_presets[key] or custom_presets[key] then
            api.nvim_err_writeln(string.format("Preset '%s' already exists!", key))
        else
            custom_presets[key] = val
        end
    end,
    __metatable = false,
}

return setmetatable({}, presets_mt)
