# feline.nvim
A minimal, stylish and customizable statusline for Neovim written in Lua

Requires Neovim >= 0.5

## About
Feline is a lua statusline inspired by [galaxyline](https://github.com/glepnir/galaxyline.nvim), but being more minimal and keeping complete customizability in mind. Feline is less of a statusline unto itself but more of a framework for you to easily build your own statusline while being to tweak every tiny bit to your heart's content. But for those who want to just get stuff done, Feline also provides a default statusline which should fit the needs of most people.

## Features
* Ease-of-use.
* Completely customizability over every component.
* Built-in providers for things like vi-mode, file info, file size, cursor position, diagnostics (using [Neovim's buiilt-in LSP](https://neovim.io/doc/user/lsp.html)), git branch and diffs (using [gitsigns.nvim](https://github.com/lewis6991/gitsigns.nvim/)), etc.
* Minimalistic, only provides the bare minimum and allows the user to build their own components very easily.

## Requirements
* Necessary
    * Neovim >= 0.5
    * [A patched font](https://github.com/ryanoasis/nerd-fonts/)
    * Truecolor support for Neovim (with `set termguicolors` and a truecolor supporting Terminal / GUI)
* Optional
    * [gitsigns.nvim](https://github.com/lewis6991/gitsigns.nvim/) - For git info
    * [nvim-lspconfig](https://github.com/neovim/nvim-lspconfig/) - To configure LSP for diagnostics)

## Screenshots
![image](https://user-images.githubusercontent.com/29580810/114544000-d3028400-9c7b-11eb-856c-2feb166334b2.png)

## How to install
* [packer.nvim](https://github.com/wbthomason/packer.nvim/):
```
use 'famiu/feline.nvim'
```

* [paq-nvim](https://github.com/savq/paq-nvim/)
```
paq 'famiu/feline.nvim'
```

* [vim-plug](https://github.com/junegunn/vim-plug/):
```
Plug 'famiu/feline.nvim'
```

* Using Neovim's built-in plugin manager (Linux or MacOS):<br><br>Open your Terminal and enter the following command:
```bash
git clone https://github.com/famiu/feline.nvim/ ~/.local/share/nvim/site/pack/feline.nvim/start/feline.nvim/
```

* Using Neovim's built-in plugin manager (Windows):<br><br>Open Powershell and enter the following command:
```powershell
git clone https://github.com/famiu/feline.nvim/ ~\AppData\Local\nvim-data\site\pack\feline.nvim\start\feline.nvim\
```

## How to use
Once you've installed Feline, it's very easy to start using it. Here are the following options for using Feline:

### 1. Using default statusline.

If you want an opinionated statusline that "just works", then you can just use Feline's default statusline, for which you just have to add the `setup()` function to your config:
```lua
require('feline').setup()
```

You can also make minor tweaks like changing the default foreground and background color like this:
```lua
require('feline').setup({
    default_fg = '#D0D0D0',
    default_bg = '#1F1F23'
})
```
### 2. Building your own statusline.

If you don't mind getting your hands dirty, then I recommend making your own statusline, it's very easy to do so, but for that you have to first understand how Feline works.<br><br>Feline has a statusline generator that takes a `components` value and a `properties` value, both of them are Lua tables. The `components` table needs to contain the statusline components while the `properties` table needs to contain the statusline properties.

#### Components
Inside the `components` table, there needs to be two more tables, `left` and `right`, which will dictate if the component should be put in the left side or the right side of the statusline. And in each of the `left` and `right` tables, there needs to be two more tables, `active` and `inactive`, which will dictate whether the component is a part of the statusline when it's in the active window or the inactive window.

So first, in your init.lua file, you have to initialize the components table
```lua
-- Initialize the components table
local components = {
    left = {active = {}, inactive = {}},
    right = {active = {}, inactive = {}}
}
```

You can then add new components to by adding an element to the `active` or `inactive` table inside either the `left` or `right` table. For example: 

```lua
-- Insert a component that will be on the left side of the statusline
-- when the window is active:
table.insert(components.left.active, {
    -- Component info here
})

-- Insert a component that will be on the right side of the statusline
-- when the window is active:
table.insert(components.right.active, {
    -- Component info here
})

-- Insert a component that will be on the left side of the statusline
-- when the window is inactive:
table.insert(components.left.inactive, {
    -- Component info here
})

-- Insert a component that will be on the right side of the statusline
-- when the window is inactive:
table.insert(components.left.right.inactive, {
    -- Component info here
})
```
Alternatively you can also use Lua table indexes instead of table.index, like::
```lua
-- Insert a component that will be on the right side of the statusline
-- when the window is active:
components.right.active[1] = {
    -- Component info here
}

-- Insert another component that will be on the right side of the statusline
-- when the window is active:
components.right.active[2] = {
    -- Component info here
}
```

**NOTE:** If you use the index instead of table.insert, remember to put the correct index.

Now, you can customize each component to your liking. Most values that a component requires can also use a function without arguments that Feline will automatically evaluate. But in case a function is provided, the type of value the function returns must be the same as the type of value required by the component. For example, since `provider` requires a string value, if you set it to a function, the function must also return a string value. Note that you can omit all of the component values except `provider`, in which case the defaults would be used instead. A component can have the following values:

* `provider` (string): Text to show
```lua
-- Provider that shows current line in file
provider = function()
    return string.format('%d:%d', vim.fn.line('.'), vim.fn.col('.'))
end

-- Providers can also just contain a simple string, such as:
provider = 'some text here'
```

There are also some [default providers](#default-providers), to use them, you just use the provider name like this:
```lua
provider = 'position' -- This will use the default file position provider.
```

Note that you can also use your [manually added providers](#adding-your-own-provider) the same way

* `enabled` (boolean): Determines if the component is enabled. If false, the component is not shown in the statusline. For example:
```lua
-- Enable if opened file has a valid size
enabled = function()
    return vim.fn.getfsize(vim.fn.expand('%:t')) > 0
end
```

* `hl` (table): Determines the highlight settings. The hl table can have three values:
    * `hl.fg` (string): RGB hex or [name](#default-colors) of forground color. (eg: `'#FFFFFF'`).<br>By default it uses the default foreground color provided in the `setup()` function.
    * `hl.bg` (string): RGB hex or [name](#default-colors) of background color. (eg: `#000000'`).<br>By default it uses the default background color provided in the `setup()` function.
    * `hl.style` (string): Formatting style of text. (eg: `'bold,undercurl'`).<br>By default it is set to `'NONE'`
    * `hl.name` (string): Name of highlight group created by Feline (eg: `'VimInsert'`).<br><br>Note that `'StatusComponent'` is prepended to the name you provide. So if you provide the name `VimInsert`, the highlight group created will have the name `StatusComponentVimInsert`.<br><br>If a name is not provided, Feline automatically generates a unique name for the highlight group based on the other values.

An example of using the hl group:
```lua
-- As a table
hl = {
    fg = 'skyblue'
}

-- As a function
hl = function()
    local val = {}

    val.name = require('feline.providers.vi_mode').get_mode_highlight_name()
    val.fg = require('feline.providers.vi_mode').get_mode_color()
    val.style = 'bold'

    return val
end
```

##### Separators
Separators are both the simplest and the trickiest part of Feline. There are two types of separator values that you can put in a component, which are `left_sep` and `right_sep`, which represent the separator on the left or the right side of the component, respectively.

The value of `left_sep` and `right_sep` can just be set to a string that is displayed. You can use a function that returns a string just like the other component values. The value can also be equal to the name of one of the [default seperators](#default-separators). The value of `left_sep` and `right_sep` can also be a table or a function returning a table, in which there would be two values, `str` and `hl`, where `str` would represent the separator string and `hl` would represent the separator highlight. The separator's highlight works just like the component's `hl` value. The only difference is that the separator's `hl` by default uses the parent's background color as its foreground color.

But you can also set `left_sep` and `right_sep` to be a `table` containing multiple separator elements, you can use this if you want to have different highlights for the left or right separator of the same component or if you want to better organize your seperator components.

For example:
```lua
-- Setting sep to a string
left_sep = ' '

-- Setting sep to a default separator
left_sep = 'slant_right'

-- Setting sep to a table with highlight
left_sep = {
    str = 'slant_left',
    hl = {
        fg = 'oceanblue',
        bg = 'bg'
    }
}

-- Setting sep to a function
right_sep = function()
    local val = {hl = {fg = 'NONE', bg = 'black'}}
    if vim.b.gitsigns_status_dict then val.str = ' ' else val.str = '' end

    return val
end

-- Setting sep to a list separator elements
right_sep = {
    {
        str = ' ',
        hl = {
            fg = 'NONE',
            bg = 'oceanblue'
        }
    },
    -- The line below is equivalent to { str = 'slant_right' }
    'slant_right'
}
```

##### Component example
Now that we know of the possible values you can set in a component, let's make some actual components to show you how it all looks like together:

[**NOTE:** Remember to initialize the components table before assigning anything to it]
```lua
-- Component that shows Vi mode with highlight
components.left.active[1] = {
    provider = 'vi_mode',
    hl = function()
        local val = {}

        val.name = vi_mode_utils.get_mode_highlight_name()
        val.fg = vi_mode_utils.get_mode_color()
        val.style = 'bold'

        return val
    end,
    right_sep = ' '
}

-- Component that shows file info
components.left.active[2] = {
    provider = 'file_info',
    hl = {
        fg = 'white',
        bg = 'oceanblue',
        style = 'bold'
    },
    left_sep = {' ', 'slant_left_2'},
    right_sep = {'slant_right_2', ' '}
}

-- Components that show current file size
components.left.active[1] = {
    provider = 'file_size',
    enabled = function() return vim.fn.getfsize(vim.fn.expand('%:t')) > 0 end,
    right_sep = {
        ' ',
        {
            str = 'slant_left_2_thin',
            hl = {
                fg = 'fg',
                bg = 'bg'
            }
        },
        ' '
    }
}

-- Component that shows current git branch
components.right.active[1] = {
    provider = 'git_branch',
    hl = {
        fg = 'white',
        bg = 'black',
        style = 'bold'
    },
    right_sep = function()
        local val = {hl = {fg = 'NONE', bg = 'black'}}
        if vim.b.gitsigns_status_dict then val.str = ' ' else val.str = '' end

        return val
    end
}
```

##### Default values
For your ease of use, Feline has some default color and separator values set. You can manually access them through `require('feline').colors` and `require('feline').separators` respectively, but there is a much easier way to use them, that is to just directly assign the name of the color or separator to the value, eg:
```lua
hl = {bg = 'oceanblue'},
right_sep = 'slant_right'
```

Below is a list of all the default value names and their values:
###### Default Colors
```lua
bg = '#1F1F23'
black = '#1B1B1B'
skyblue = '#50B0F0'
cyan = '#009090'
fg = '#D0D0D0'
green = '#60A040'
oceanblue = '#0066cc'
magenta = '#C26BDB'
orange = '#FF9000'
red = '#D10000'
violet = '#9E93E8'
white = '#FFFFFF'
yellow = '#E1E120'
```

###### Default Separators
```lua
vertical_bar = '┃',
vertical_bar_thin = '│',
left = '',
right = '',
left_filled = '',
right_filled = '',
slant_left = '',
slant_left_thin = '',
slant_right = '',
slant_right_thin = '',
slant_left_2 = '',
slant_left_2_thin = '',
slant_right_2 = '',
slant_right_2_thin = '',
left_rounded = '',
left_rounded_thin = '',
right_rounded = '',
right_rounded_thin = '',
circle = '●'
```

#### Properties
Besides components, the generator may also have a `properties` table. The `properties` table only needs one element, which is the table `force_inactive`, it represents which buffer types, filetypes or buffer names will always have the inactive statusline, regardless of whether they're active or inactive. You may need that in order to prevent irrelevant or unneeded information from being shown on buffers like the file tree, terminal, etc. Finally, `force_inactive` needs three elements in it, `filetypes`, `buftypes` and `bufnames`, all of which are tables containing the filetypes, buffer types and buffer names respectively that will be forced to have the inactive statusline. Here's an example of how to set the properties table
```lua
-- Initialize the properties table
properties = {
    force_inactive = {
        filetypes = {},
        buftypes = {},
        bufnames = {}
    }
}

properties.force_inactive.filetypes = {
    'NvimTree',
    'dbui',
    'packer',
    'startify',
    'fugitive',
    'fugitiveblame'
}

properties.force_inactive.buftypes = {
    'terminal'
}

properties.force_inactive.bufnames = {
    'some_buffer_name'
}
```
And that's it, that's how you set up the properties table

#### The setup() function
Now that we've learned to set up both the components table and the properties table, it's finally time to revisit the setup function. The setup function takes a table that can have the following values:
* `default_fg` - [Name](#default-colors) or RGB hex code of default foreground color.
* `default_bg` - [Name](#default-colors) or RGB hex code of default background color.
* `components` - The components table
* `properties` - The properties table
* `vi_mode-colors` - A table containing colors associated with Vi modes. It can later be used to get the color associated with the current Vim mode using `require('feline.providers.vi_mode').get_mode_color()`. Here is a list of all possible vi_mode names used with the default color associated with them:
```lua
NORMAL = 'green'         -- Normal mode
OP = 'green'             -- Operator pending mode
INSERT = 'red'           -- Insert mode
VISUAL = 'skyblue'       -- Visual mode
BLOCK = 'skyblue'        -- Visual block mode
REPLACE = 'violet'       -- Replace mode
['V-REPLACE'] = 'violet' -- Virtual Replace mode
ENTER = 'cyan'           -- Enter mode
MORE = 'cyan'            -- More mode
SELECT = 'orange'        -- Select mode
COMMAND = 'green'        -- Command mode
SHELL = 'green'          -- Shell mode
TERM = 'green'           -- Terminal mode
NONE = 'yellow'          -- None
```

#### Example config
It's finally time to see a fully-fledged example of how to set up the statusline. Here is an example config that's actually the same as the default config, except it's set-up manually:
```lua
local lsp = require('feline.providers.lsp')
local vi_mode_utils = require('feline.providers.vi_mode')

local properties = {
    force_inactive = {
        filetypes = {},
        buftypes = {},
        bufnames = {}
    }
}

local components = {
    left = {
        active = {},
        inactive = {}
    },
    right = {
        active = {},
        inactive = {}
    }
}

properties.force_inactive.filetypes = {
    'NvimTree',
    'dbui',
    'packer',
    'startify',
    'fugitive',
    'fugitiveblame'
}

properties.force_inactive.buftypes = {
    'terminal'
}

components.left.active[1] = {
    provider = '▊ ',
    hl = {
        fg = 'skyblue'
    }
}

components.left.active[2] = {
    provider = 'vi_mode',
    hl = function()
        local val = {}

        val.name = vi_mode_utils.get_mode_highlight_name()
        val.fg = vi_mode_utils.get_mode_color()
        val.style = 'bold'

        return val
    end,
    right_sep = ' '
}

components.left.active[3] = {
    provider = 'file_info',
    hl = {
        fg = 'white',
        bg = 'oceanblue',
        style = 'bold'
    },
    left_sep = {' ', 'slant_left_2'},
    right_sep = {'slant_right_2', ' '}
}

components.left.active[4] = {
    provider = 'file_size',
    enabled = function() return vim.fn.getfsize(vim.fn.expand('%:t')) > 0 end,
    right_sep = {
        ' ',
        {
            str = 'slant_left_2_thin',
            hl = {
                fg = 'fg',
                bg = 'bg'
            }
        },
        ' '
    }
}

components.left.active[5] = {
    provider = 'position',
    right_sep = {
        ' ',
        {
            str = 'slant_right_2_thin',
            hl = {
                fg = 'fg',
                bg = 'bg'
            }
        }
    }
}

components.left.active[6] = {
    provider = 'diagnostic_errors',
    enabled = function() return lsp.diagnostics_exist('Error') end,
    hl = { fg = 'red' }
}

components.left.active[7] = {
    provider = 'diagnostic_warnings',
    enabled = function() return lsp.diagnostics_exist('Warning') end,
    hl = { fg = 'yellow' }
}

components.left.active[8] = {
    provider = 'diagnostic_hints',
    enabled = function() return lsp.diagnostics_exist('Hint') end,
    hl = { fg = 'cyan' }
}

components.left.active[9] = {
    provider = 'diagnostic_info',
    enabled = function() return lsp.diagnostics_exist('Information') end,
    hl = { fg = 'skyblue' }
}

components.right.active[1] = {
    provider = 'git_branch',
    hl = {
        fg = 'white',
        bg = 'black',
        style = 'bold'
    },
    right_sep = function()
        local val = {hl = {fg = 'NONE', bg = 'black'}}
        if vim.b.gitsigns_status_dict then val.str = ' ' else val.str = '' end

        return val
    end
}

components.right.active[2] = {
    provider = 'git_diff_added',
    hl = {
        fg = 'green',
        bg = 'black'
    }
}

components.right.active[3] = {
    provider = 'git_diff_changed',
    hl = {
        fg = 'orange',
        bg = 'black'
    }
}

components.right.active[4] = {
    provider = 'git_diff_removed',
    hl = {
        fg = 'red',
        bg = 'black'
    },
    right_sep = function()
        local val = {hl = {fg = 'NONE', bg = 'black'}}
        if vim.b.gitsigns_status_dict then val.str = ' ' else val.str = '' end

        return val
    end
}

components.right.active[5] = {
    provider = 'line_percentage',
    hl = {
        style = 'bold'
    },
    left_sep = '  ',
    right_sep = ' '
}

components.right.active[6] = {
    provider = 'scroll_bar',
    hl = {
        fg = 'skyblue',
        style = 'bold'
    }
}

components.left.inactive[1] = {
    provider = 'file_type',
    hl = {
        fg = 'white',
        bg = 'oceanblue',
        style = 'bold'
    },
    left_sep = {
        str = ' ',
        hl = {
            fg = 'NONE',
            bg = 'oceanblue'
        }
    },
    right_sep = {
        {
            str = ' ',
            hl = {
                fg = 'NONE',
                bg = 'oceanblue'
            }
        },
        'slant_right'
    }
}

local vi_mode_colors = {
    NORMAL = colors.green,
    OP = colors.green,
    INSERT = colors.red,
    VISUAL = colors.skyblue,
    BLOCK = colors.skyblue,
    REPLACE = colors.violet,
    ['V-REPLACE'] = colors.violet,
    ENTER = colors.cyan,
    MORE = colors.cyan,
    SELECT = colors.orange,
    COMMAND = colors.green,
    SHELL = colors.green,
    TERM = colors.green,
    NONE = colors.yellow
}

require('feline').setup({
    default_bg = '#1F1F23',
    default_fg = '#D0D0D0',
    components = components,
    properties = properties,
    vi_mode_colors = vi_mode_colors
})
```

### Providers
#### Default providers
Feline by default has some built-in providers to make your life easy. They are:
|Name|Description|
--|--
|[`vi_mode`](#vi-mode)|Current vi_mode|
|`position`|Get line and column number of cursor|
|`line_percentage`|Current line percentage|
|`scroll_bar`|Scroll bar that shows file progress|
|`file_info`|Get file icon, name and modified status|
|`file_size`|Get file size|
|`file_type`|Get file type|
|`git_branch`|Shows current git branch|
|`git_diff_added`|Git diff added count|
|`git_diff_removed`|Git diff removed count|
|`git_diff_changed`|Git diff changed count|
|`diagnostic_errors`|Diagnostics errors count|
|`diagnostic_warnings`|Diagnostics warnings count|
|`diagnostic_hints`|Diagnostics hints count|
|`diagnostic_info`|Diagnostics info count|

##### Vi-mode
The vi-mode provider by itself only shows an icon, to actually indicate the current Vim mode, you have to use `require('feline.providers.vi_mode').get_mode_color()` as shown in the [example config](#example-config)

##### Git
The git providers all require [gitsigns.nvim](https://github.com/lewis6991/gitsigns.nvim/), make sure you have it installed when you use this provider, otherwise it'll output nothing.

##### Diagnostics
The diagnostics providers all require the Neovim built-in LSP to be configured and at least one LSP client to be attached to the current buffer, else it'll have no output.

#### Adding your own provider
In case none of the default providers do what you want, it's very easy to add your own provider. Just call `require('feline.providers').add_provider(name, function)` where `name` is the name of the provider and `function` is the function associated with the provider, you can then use your provider the same way you use the other providers.

## Maintenance
While I chose to make this plugin available to others, I mainly created it for myself. So I may not go out of my way to fix a minor niche issue unless it gets in my way. So if you have an issue, consider making a pull request that fixes your issue instead. But by all means if you do post an issue, I will try to see if I can fix it.

## LICENSE
Feline is licensed under GNU GPLv3-or-later. For more info, see: [LICENSE.md](LICENSE.md)

## Miscellaneous
### Naming
The name of this plugin is a silly pun based on the convention of the names of statusline plugins ending with 'line', while also being named after cats. And in a way this statusline is supposed to be as quick as a cat's instincts, so I guess the name fits.

### Special thanks
[glepnir](https://github.com/glepnir) - for creating [galaxyline](https://github.com/glepnir/galaxyline.nvim) which this plugin was inspired by.
