-- Use lazy_require to only load the theme that's are being used
local api = vim.api
local lazy_require = require('feline.utils').lazy_require

local default_themes = {
    default = require('feline.themes.default'),
}

local custom_themes = {}

local themes_mt = {
    __index = function(_, key)
        if default_themes[key] then
            return default_themes[key]
        elseif custom_themes[key] then
            return custom_themes[key]
        end
    end,
    __newindex = function(_, key, val)
        if default_themes[key] or custom_themes[key] then
            api.nvim_err_writeln(string.format("Theme '%s' already exists!", key))
        else
            custom_themes[key] = val
        end
    end,
    __metatable = false,
}

return setmetatable({}, themes_mt)
