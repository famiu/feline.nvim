-- Feline benchmark test
-- Make sure you have feline.nvim and its dependencies installed and
-- run from Feline top-level directory using:
-- env AK_PROFILER=1 nvim -u benchmark/benchmark.lua > /dev/null 2>&1 | less

-- Automatically install profiler.nvim if it doesn't exist
if not pcall(require, 'profiler') then
    local install_path = '/tmp/nvim/site/pack/feline/start/profiler.nvim'

    vim.opt.packpath:append('/tmp/nvim/site')

    if vim.fn.isdirectory(install_path) == 0 then
        vim.fn.system({'git', 'clone', 'https://github.com/norcalli/profiler.nvim', install_path})
    end
end

-- Start benchmark
require('profiler').wrap(require('feline').setup())
