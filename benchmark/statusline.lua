-- Feline statusline generation benchmark test
-- Start Neovim with Feline installed and configured and source this file using the luafile command

local opt = vim.opt
local fn = vim.fn

-- Automatically install plenary.nvim if it doesn't exist
if not pcall(require, 'plenary.benchmark') then
    local install_path = '/tmp/nvim/site/pack/feline/start/plenary.nvim'

    opt.packpath:append('/tmp/nvim/site')

    if fn.isdirectory(install_path) == 0 then
        fn.system({'git', 'clone', 'https://github.com/nvim-lua/plenary.nvim', install_path})
    end
end

-- Start benchmark
local benchmark = require('plenary.benchmark')
local statusline_generator = require('feline').statusline

benchmark("Feline statusline generation benchmark", {
    runs = 10000,
    fun = {
        {
            "Generating statusline",
            statusline_generator
        }
    }
})

