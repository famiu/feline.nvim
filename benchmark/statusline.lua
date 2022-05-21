-- Feline statusline generation benchmark test
-- Start Neovim with Feline installed and configured and source this file using the luafile command

local tmpdir

if vim.fn.has('win32') == 1 then
    tmpdir = os.getenv('TEMP')
else
    tmpdir = '/tmp'
end

-- Automatically install plenary.nvim if it doesn't exist
if not pcall(require, 'plenary.benchmark') then
    local install_path = tmpdir .. '/nvim/site/pack/feline/start/plenary.nvim'

    vim.opt.packpath:append(tmpdir .. '/nvim/site')

    if vim.fn.isdirectory(install_path) == 0 then
        vim.fn.system { 'git', 'clone', 'https://github.com/nvim-lua/plenary.nvim', install_path }
    end
end

-- Start benchmark
local benchmark = require('plenary.benchmark')
local gen = require('feline.generator')

local function statusline_generator()
    gen.generate_statusline(true)
end

benchmark('Feline statusline generation benchmark', {
    runs = 10000,
    fun = {
        {
            'Generating statusline',
            statusline_generator,
        },
    },
})
