-- Utility functions used across Feline
local cmd = vim.api.nvim_command

local M = {}

-- Utility function to create augroups
function M.create_augroup(autocmds, name)
    cmd('augroup ' .. name)
    cmd('autocmd!')

    for _, autocmd in ipairs(autocmds) do
        cmd('autocmd ' .. table.concat(autocmd, ' '))
    end

    cmd('augroup END')
end

-- Lazy require function
-- Only actually `require()`s a module when it gets used
function M.lazy_require(module)
    return setmetatable({}, {
        __index = function(_, key)
            return require(module)[key]
        end,

        __newindex = function(_, _, _)
        end,

        __metatable = false
    })
end

return M
