-- Feline startup benchmark test
-- Make sure you have feline.nvim and its dependencies installed and
-- run from Feline top-level directory using:
-- env AK_PROFILER=1 nvim --noplugin -u benchmark/startup.lua > /dev/null 2>&1 | less

local opt = vim.opt
local fn = vim.fn

-- Automatically install profiler.nvim if it doesn't exist
if not pcall(require, 'profiler') then
    local install_path = '/tmp/nvim/site/pack/feline/start/profiler.nvim'

    opt.packpath:append('/tmp/nvim/site')

    if fn.isdirectory(install_path) == 0 then
        fn.system({'git', 'clone', 'https://github.com/norcalli/profiler.nvim', install_path})
    end
end

-- Setup gitsigns
local ok, gitsigns = pcall(require, 'gitsigns')
if ok then gitsigns.setup() end

-- Start benchmark
require('profiler').wrap(require('feline').setup())
