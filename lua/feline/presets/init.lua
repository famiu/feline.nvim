-- Use an immutable table to only automatically load the preset that's are being used
local M = setmetatable({}, {
    __index = function(_, key)
        local ok, result = pcall(require, 'feline.presets.' .. key)
        if ok then return result else return nil end
    end,

    __newindex = function(_, _, _)
    end,

    __metatable = false
})

return M

