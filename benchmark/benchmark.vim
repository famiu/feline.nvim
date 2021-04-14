"" Feline benchmark test
"" Requires 'norcalli/profiler.nvim'
"" Run from Feline top-level directory using:
"" env AK_PROFILER=1 nvim 2>&1 -u benchmark/benchmark.vim >/dev/null | less

packadd profiler.nvim
packadd nvim-web-devicons
packadd feline.nvim

lua <<EOF
local profiler = require('profiler')
profiler.wrap(require('feline').setup())
EOF
