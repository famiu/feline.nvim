-- Utility functions used across Feline
local cmd = vim.api.nvim_command

local M = {}

-- Utility function to create augroups
function M.create_augroup(autocmds, name, no_clear)
    cmd('augroup ' .. name)

    if no_clear == nil or no_clear == false then
        cmd('autocmd!')
    end

    for _, autocmd in ipairs(autocmds) do
        cmd('autocmd ' .. table.concat(autocmd, ' '))
    end

    cmd('augroup END')
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

return M
