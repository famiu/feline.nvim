"" Feline benchmark test
"" Requires 'norcalli/profiler.nvim' as an opt plugin
"" Make sure you have feline.nvim and nvim-web-devicons installed as start plugins
"" Run from Feline top-level directory using:
"" env AK_PROFILER=1 nvim 2>&1 -u benchmark/benchmark.vim >/dev/null | less

packadd profiler.nvim

lua <<EOF
local profiler = require('profiler')
profiler.wrap(require('feline').setup())
EOF
