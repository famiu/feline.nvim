-- install packer
local fn = vim.fn
local cmd = vim.cmd

local install_path = '/tmp/nvim/site/pack/packer/start/packer.nvim'

cmd('set packpath=/tmp/nvim/site')

local function load_plugins()
    require('packer').startup {
        function(use)
            use 'wbthomason/packer.nvim'
            use {
                'famiu/feline.nvim',
                requires = {
                    {
                        'lewis6991/gitsigns.nvim',
                        requires = { 'nvim-lua/plenary.nvim' },
                        config = function()
                            require('gitsigns').setup()
                        end
                    },
                    'kyazdani42/nvim-web-devicons'
                }
            }
        end,

        config = {
            package_root = '/tmp/nvim/site/pack',
            git = {
                clone_timeout = -1
            }
        }
    }
end

_G.load_config = function()
    cmd('set termguicolors')

    -- Replace this part of the config with whatever Feline configuration you're using
    require('feline').setup()
end

if fn.isdirectory(install_path) == 0 then
    fn.system({'git', 'clone', 'https://github.com/wbthomason/packer.nvim', install_path})
end

load_plugins()
require('packer').sync()
cmd('autocmd User PackerComplete ++once lua load_config()')

