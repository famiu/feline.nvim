# feline.nvim

A minimal, stylish and customizable statusline for Neovim written in Lua

Requires Neovim >= 0.5

## About

Feline is a lua statusline inspired by [galaxyline](https://github.com/glepnir/galaxyline.nvim), but being more minimal and keeping complete customizability in mind. Feline is less of a statusline unto itself but more of a framework for you to easily build your own statusline on, while being able to tweak every tiny bit to your heart's content. But for those who just want to get stuff done, Feline also provides a default statusline which should fit the needs of most people.

## Features

- Ease-of-use.
- Complete customizability over every component.
- Built-in providers for things like vi-mode, file info, file size, cursor position, diagnostics (using [Neovim's buiilt-in LSP](https://neovim.io/doc/user/lsp.html)), git branch and diffs (using [gitsigns.nvim](https://github.com/lewis6991/gitsigns.nvim/)), etc.
- Minimalistic, only provides the bare minimum and allows the user to build their own components very easily.

## Requirements

- Necessary
  - Neovim >= 0.5
  - Truecolor support for Neovim (with `set termguicolors` and a truecolor supporting Terminal / GUI)
- Optional
  - [nvim-web-devicons](https://github.com/kyazdani42/nvim-web-devicons/) - For icon support
  - [A patched font](https://github.com/ryanoasis/nerd-fonts/) - For icon support
  - [gitsigns.nvim](https://github.com/lewis6991/gitsigns.nvim/) - For git info

## Screenshots

**NOTE: Some of these configurations may be outdated and may need to be changed prior to use.**

**Default setup:**
![image](https://user-images.githubusercontent.com/29580810/114544000-d3028400-9c7b-11eb-856c-2feb166334b2.png)

**Default no-icons setup:**
![image](https://user-images.githubusercontent.com/29580810/114742106-36201380-9d6d-11eb-9866-e8c0fef8a1bd.png)

**[Config by crivotz:](https://github.com/crivotz/nv-ide/blob/master/lua/plugins/feline.lua)**
![image](https://user-images.githubusercontent.com/3275600/114841377-0ce89d00-9dd8-11eb-82b4-b3ee332771c2.png)

**[Config by 6cdh:](https://github.com/6cdh/dotfiles/blob/62959d27344dade28d6dd638252cd82accb309ab/nvim/.config/nvim/lua/statusline.lua)**
![image](https://user-images.githubusercontent.com/39000776/114838041-e68e2600-9e06-11eb-9334-431a627ff144.png)

**Config by luizcoro2:**
![image](https://user-images.githubusercontent.com/70335871/115327167-dd81b980-a164-11eb-9c02-7a3a1b6a94b5.png)

**Config by rafamadriz (classic):**

**Gruvbox:**
![image](https://user-images.githubusercontent.com/67771985/116002735-a7bc5500-a5ea-11eb-82e3-86d1837902cf.png)
**Nord:**
![image](https://user-images.githubusercontent.com/67771985/116002779-d3d7d600-a5ea-11eb-8772-7cb85d7bc324.png)

**Config by rafamadriz (slant):**

**Gruvbox:**
![image](https://user-images.githubusercontent.com/67771985/116002799-e94d0000-a5ea-11eb-9472-da0d75bbcceb.png)
**Nord:**
![image](https://user-images.githubusercontent.com/67771985/116002808-efdb7780-a5ea-11eb-97eb-caf7875e9a3d.png)

**Config by rafamadriz (VSCode):**
![image](https://user-images.githubusercontent.com/67771985/117713773-9d42b380-b1c5-11eb-8a8b-76949c9b2db1.png)

**[Config by pianocomposer321:](https://gist.github.com/pianocomposer321/6151c458132a97590d21415db67361a6)**
![image](https://user-images.githubusercontent.com/54072354/117869424-65d51500-b260-11eb-898c-0a0b987a6275.png)

**NOTE: You can add your own configuration to this list. If you're interested, simply make a pull request and I'll add it.**

## How to install

- [packer.nvim](https://github.com/wbthomason/packer.nvim/):

```
use 'famiu/feline.nvim'
```

- [paq-nvim](https://github.com/savq/paq-nvim/)

```
paq 'famiu/feline.nvim'
```

- [vim-plug](https://github.com/junegunn/vim-plug/):

```
Plug 'famiu/feline.nvim'
```

- Using Neovim's built-in plugin manager (Linux or MacOS):<br><br>Open your Terminal and enter the following command:

```bash
git clone https://github.com/famiu/feline.nvim/ ~/.local/share/nvim/site/pack/feline.nvim/start/feline.nvim/
```

- Using Neovim's built-in plugin manager (Windows):<br><br>Open Powershell and enter the following command:

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

In case you don't like icons and want to use the default statusline configuration without icons, just do:

```lua
require('feline').setup({
    preset = 'noicon'
})
```

NOTE: This is also the configuration used by default if you don't have `nvim-web-devicons`. You don't have to specify it manually in case you don't have `nvim-web-devicons`. In that case, Feline will detect that you don't have `nvim-web-devicons` and automatically pick the `noicon` preset.

You can also make minor tweaks like changing the default foreground and background color like this:

```lua
require('feline').setup {
    colors = {
        fg = '#D0D0D0',
        bg = '#1F1F23'
    }
}
```

### 2. Building your own statusline.

If you don't mind getting your hands dirty, then I recommend making your own statusline, it's very easy to do so, but for that you have to first understand how Feline works.<br><br>Feline has a statusline generator that takes a `components` value, which is a Lua table that needs to contain the statusline components.

#### Components

Inside the `components` table, there needs to be two tables, `active` and `inactive`, which will dictate whether the component is a part of the statusline when it's in an active window or an inactive window. And inside each of the `active` and `inactive` tables, you can put any amount of tables, each of which will indicate a section of the statusline. For example, if you want two sections (left and right), you can put two tables inside each of the `active` and `inactive` tables. If you want three sections (left, mid and right), you can put three tables inside each of the `active` and `inactive` tables. There is no limit to the amount of sections you can have. It's also possible to have a different amount of sections for the `active` and `inactive` statuslines. 

So first, in your init.lua file, you have to initialize the components table

```lua
-- Initialize the components table
local components = {
    active = {},
    inactive = {}
}
```

You can then add new sections to the statusline by adding an element to the `active` or `inactive` tables. For example:

```lua
-- Insert three sections (left, mid and right) for the active statusline
table.insert(components.active, {})
table.insert(components.active, {})
table.insert(components.active, {})

-- Insert two sections (left and right) for the inactive statusline
table.insert(components.inactive, {})
table.insert(components.inactive, {})
```

Now you can add statusline components to each of those sections by adding elements to the sections.
For example:

```lua
-- Insert a component that will be on the left side of the statusline
-- when the window is active:
table.insert(components.active[1], {
    -- Component info here
})

-- Insert another component that will be on the left side of the statusline
-- when the window is active:
table.insert(components.active[1], {
    -- Component info here
})

-- Insert a component that will be on the middle of the statusline
-- when the window is active:
table.insert(components.active[2], {
    -- Component info here
})

-- Insert a component that will be on the right side of the statusline
-- when the window is active:
table.insert(components.active[3], {
    -- Component info here
})

-- Insert a component that will be on the left side of the statusline
-- when the window is inactive:
table.insert(components.inactive[1], {
    -- Component info here
})

-- Insert a component that will be on the right side of the statusline
-- when the window is inactive:
table.insert(components.inactive[2], {
    -- Component info here
})
```

Alternatively you can also use Lua table indices instead of table.insert, like:

```lua
-- Insert a component that will be on the right side of the statusline
-- when the window is active:
components.active[3][1] = {
    -- Component info here
}

-- Insert another component that will be on the right side of the statusline
-- when the window is active:
components.active[3][2] = {
    -- Component info here
}
```

**NOTE:** If you use the index instead of table.insert, remember to put the correct index. Also keep in mind that unlike most other programming languages, Lua indices start at `1` instead of `0`.

Now you can customize each component to your liking. Most values that a component requires can also use a function without arguments, with the exception of the `provider` and `enabled` values, which can take arguments (more about that below). Feline will automatically evaluate the function if it is given a function. But in case a function is provided, the type of value the function returns must be the same as the type of value required by the component. For example, since `enabled` requires a boolean value, if you set it to a function, the function must also return a boolean value. Note that you can omit all of the component values except `provider`, in which case the defaults would be used instead. A component can have the following values:

- `provider` (string or function): If it's a string, it represents the text to show. If it's a function, it must return a string when called. As a function it may also optionally return an `icon` component alongside the string when called, which would represent the provider's icon, possibly along with the icon highlight group configuration. The function can take either no arguments, or one argument which would contain the component itself, or it can take two arguments, the component and the window handler of the window for which the statusline is being generated.

```lua
-- Provider that shows current line in file
provider = function()
    return string.format('%d:%d', vim.fn.line('.'), vim.fn.col('.'))
end

-- Providers can also take the component as an argument
provider = function(component)
    if component.icon then
        return component.icon
    else
        return ''
    end
end

-- Providers can also take the window handler as an argument
provider = function(component, winid)
    return (component.icon or '') .. tostring(vim.api.nvim_win_get_buf(winid))
end

-- If you only need the window handler, you can avoid using the component value like this:
provider = function(_, winid)
    return vim.api.nvim_win_get_cursor(winid)[1]
end

-- Providers can also simply just contain a string, such as:
provider = 'some text here'
```

There are also some [default providers](#default-providers), to use them, you just use the provider name like this:

```lua
provider = 'position' -- This will use the default file position provider.
```

Note that you can also use your [manually added providers](#adding-your-own-provider) the same way

- `enabled` (boolean or function): Determines if the component is enabled. If false, the component is not shown in the statusline. If it's a function that returns a boolean value, it can take either the window handler as an argument, or it can take no arguments. For example:

```lua
-- Enable if opened file has a valid size
enabled = function()
    return vim.fn.getfsize(vim.fn.expand('%:p')) > 0
end

-- Enable if current window width is higher than 80
enabled = function(winid)
    return vim.api.nvim_win_get_width(winid) > 80
end
```

- `icon` (table or string): Some inbuilt providers such as `git_branch` provide default icons. If you either don't have a patched font or don't like the default icon that Feline provides, you may set this value to use any icon you want instead. By default, the icon inherits the component's highlight, but you can also change the highlight specifically for the icon. To do this, you need to pass a table containing `str` and `hl`, where `str` would represent the icon and `hl` would represent the icon highlight. The icons's highlight works just like the `hl` component's values. For example:

```lua
-- Setting icon to a string
icon = ' + '

-- Setting icon to a function
icon = function() return ' - ' end

-- Setting icon to a table
icon = {
    str = ' ~ ',
    hl = { fg = 'orange' },
}
```

- `hl` (table or string): Determines the highlight settings.<br>
If a string, it'll use the given string as the name of the component highlight group. In that case, this highlight group must be defined elsewhere (i.e. in your colorscheme or your nvim config).<br>
If it's a table, it'll automatically generate a highlight group for you based on the given values. The hl table can have three values:
  - `hl.fg` (string): RGB hex or [name](#value-presets) of foreground color. (eg: `'#FFFFFF'`, `'white'`).<br>By default it uses the default foreground color provided in the `setup()` function.
  - `hl.bg` (string): RGB hex or [name](#value-presets) of background color. (eg: `#000000'`, `'black'`).<br>By default it uses the default background color provided in the `setup()` function.
  - `hl.style` (string): Formatting style of text. (eg: `'bold,undercurl'`).<br>By default it is set to `'NONE'`
  - `hl.name` (string): Name of highlight group created by Feline (eg: `'StatusComponentVimInsert'`).<br><br>Note that if `hl` is a function that can return different values, the highlight is not redefined if the name stays the same. Feline only creates highlights when they don't exist, it never redifines existing highlights. So if `hl` is a function that can return different values for `hl.fg`, `hl.bg` or `hl.style`, make sure to return a different value for `hl.name` as well if you want the highlight to actually change. If a name is not provided, Feline automatically generates a unique name for the highlight group based on the other values. So you can also just omit the `name` and Feline will create new highlights for you when required.<br><br>Setting `hl.name` may provide a performance improvement since Feline caches highlight names and doesn't take the time to generate a name if the name is already provided by the user.

An example of using the hl group:

```lua
-- As a table
hl = {
    fg = 'skyblue'
}

-- As a string
hl = "MyStatuslineHLGroup"

-- As a function returning a table
hl = function()
    return {
        name = require('feline.providers.vi_mode').get_mode_highlight_name(),
        fg = require('feline.providers.vi_mode').get_mode_color(),
        style = 'bold'
    }
end

-- As a function returning a string
hl = function()
  if require("feline.providers.vi_mode).get_vim_mode() == "NORMAL" then
    return "MyStatuslineNormal"
  else
    return "MyStatuslineOther"
  end
end
```

<br>

**NOTE:** Some providers may also have special component values unique to them, such as the `file_info` provider having a `file_modified_icon` value that you can set. For more info, see: [default providers](#default-providers).
<br><br>

##### Separators

Separators are both the simplest and the trickiest part of Feline. There are two types of separator values that you can put in a component, which are `left_sep` and `right_sep`, which represent the separator on the left and the right side of the component, respectively.

The value of `left_sep` and `right_sep` can just be set to a string that's displayed. You can use a function that returns a string just like the other component values. The value can also be equal to the name of one of the [separator presets](#value-presets).

The value of `left_sep` and `right_sep` can also be a table or a function returning a table. Inside the table there can be three values, `str`, `hl` and `always_visible`. `str` represents the separator string and `hl` represents the separator highlight. The separator's highlight works just like the component's `hl` value. The only difference is that the separator's `hl` by default uses the parent's background color as its foreground color.

By default, Feline doesn't show the separator if the value returned by the provider is empty. If you want the separator to be shown even when the component string is empty, you can set the `always_visible` value in the separator table to `true`. If unset or set to `false`, the separator is not shown if the component string is empty.

You can also set `left_sep` and `right_sep` to be a `table` containing multiple separator elements. It's useful if you want to have different highlights for different parts of the left/right separator of the same component, or if you want to always show certain parts of the separator regardless of whether the component string is empty, or if you just want to better organize the component's separator.

For example:

```lua
-- Setting sep to a string
left_sep = ' '

-- Setting sep to a separator preset
left_sep = 'slant_right'

-- Setting sep to a table with highlight
left_sep = {
    str = 'slant_left',
    hl = {
        fg = 'oceanblue',
        bg = 'bg'
    }
}

-- Making sep always visible
right_sep = {
    str = ' ',
    always_visible = true
}

-- Setting sep to a function
right_sep = function()
    local values = { 'right_rounded', 'right_filled', 'right' }
    return values[math.random(#values)]
end

-- Setting sep to a list separator elements
right_sep = {
    {
        str = ' ',
        hl = {
            fg = 'NONE',
            bg = 'oceanblue'
        },
        always_visible = true
    },
    -- The line below is equivalent to { str = 'slant_right' }
    'slant_right'
}
```

##### Component example

Now that we know of the possible values you can set in a component, let's make some actual components to show you how it all looks like together:

<details>
<summary>Component example</summary>

```lua
-- Component that shows Vi mode with highlight
components.active[1][1] = {
    provider = 'vi_mode',
    hl = function()
        return {
            name = require('feline.providers.vi_mode').get_mode_highlight_name(),
            fg = require('feline.providers.vi_mode').get_mode_color(),
            style = 'bold'
        }
    end,
    right_sep = ' '
}

-- Component that shows file info
components.active[1][2] = {
    provider = 'file_info',
    hl = {
        fg = 'white',
        bg = 'oceanblue',
        style = 'bold'
    },
    left_sep = {' ', 'slant_left_2'},
    right_sep = {'slant_right_2', ' '},
    -- Uncomment the next line to disable file icons
    -- icon = ''
}

-- Component that shows current file size
components.active[1][3] = {
    provider = 'file_size',
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

-- Component that shows file encoding
components.active[2][1] = {
    provider = 'file_encoding'
}

-- Component that shows current git branch
components.active[3][1] = {
    provider = 'git_branch',
    hl = {
        fg = 'white',
        bg = 'black',
        style = 'bold'
    },
    right_sep = {
        str = ' ',
        hl = {
            fg = 'NONE',
            bg = 'black'
        }
    }
}
```
</details>

[**NOTE:** Remember to initialize the components table before assigning anything to it]

##### Value presets

Value presets are names for colors and separators that you can use instead of the hex code or separator string, respectively.

For your ease of use, Feline has some default color and separator values set. You can manually access them through `require('feline.defaults').colors` and `require('feline.defaults').separators` respectively. But there's a much easier way to use them, which is to just directly assign the name of the color or separator to the value, eg:

```lua
hl = {bg = 'oceanblue'},
right_sep = 'slant_right'
```

Not only that, you can add your own custom colors and separators through [the setup function](#the-setup-function) which allows you to just use the name of the color or separator to refer to it.

Below is a list of all the default value names and their values:

###### Default colors
| Name        | Value       |
| ----------- | ----------- |
| `fg`        | `'#D0D0D0'` |
| `bg`        | `'#1F1F23'` |
| `black`     | `'#1B1B1B'` |
| `skyblue`   | `'#50B0F0'` |
| `cyan`      | `'#009090'` |
| `green`     | `'#60A040'` |
| `oceanblue` | `'#0066cc'` |
| `magenta`   | `'#C26BDB'` |
| `orange`    | `'#FF9000'` |
| `red`       | `'#D10000'` |
| `violet`    | `'#9E93E8'` |
| `white`     | `'#FFFFFF'` |
| `yellow`    | `'#E1E120'` |

###### Default Separators
| Name                 | Value |
| -------------------- | ----- |
| `vertical_bar`       | `'┃'` |
| `vertical_bar_thin`  | `'│'` |
| `left`               | `''` |
| `right`              | `''` |
| `block`              | `'█'` |
| `left_filled`        | `''` |
| `right_filled`       | `''` |
| `slant_left`         | `''` |
| `slant_left_thin`    | `''` |
| `slant_right`        | `''` |
| `slant_right_thin`   | `''` |
| `slant_left_2`       | `''` |
| `slant_left_2_thin`  | `''` |
| `slant_right_2`      | `''` |
| `slant_right_2_thin` | `''` |
| `left_rounded`       | `''` |
| `left_rounded_thin`  | `''` |
| `right_rounded`      | `''` |
| `right_rounded_thin` | `''` |
| `circle`             | `'●'` |

#### The setup function

Now that we've learned to set up both the components table, it's finally time to revisit the setup function. The setup function takes a table that can have the following values:

- `preset` - Set it to use a preconfigured statusline. Currently it can be equal to either `default` for the default statusline or `noicon` for the default statusline without icons. You don't have to put any of the other values if you use a preset, but if you do, your settings will override the preset's settings. To see more info such as how to modify a preset to build a statusline, see: [Modifying an existing preset](#3.-modifying-an-existing-preset)
- `components` - The components table.
- `colors` - A table containing custom [color value presets](#value-presets).
- `separators` - A table containing custom [separator value presets](#value-presets).
- `update_triggers` - A list of autocmds that trigger an update of the statusline in inactive windows.<br>
Default: `{'VimEnter', 'WinEnter', 'WinClosed', 'FileChangedShellPost'}`
- `force_inactive` - A table that determines which buffers should always have the inactive statusline, even when they are active. It can have 3 values inside of it, `filetypes`, `buftypes` and `bufnames`, all three of them are tables which contain file types, buffer types and buffer names respectively.<br><br>
Default:
```lua
{
    filetypes = {
        'NvimTree',
        'packer',
        'startify',
        'fugitive',
        'fugitiveblame',
        'qf',
        'help'
    },
    buftypes = {
        'terminal'
    },
    bufnames = {}
}
```
- `disable` - Similar to `force_inactive`, except the statusline is disabled completely. Configured the same way as `force_inactive`. Feline doesn't disable the statusline on anything by default.
- `vi_mode_colors` - A table containing colors associated with Vi modes. It can later be used to get the color associated with the current Vim mode using `require('feline.providers.vi_mode').get_mode_color()`. For more info on it see the [Vi-mode](#vi-mode) section.<br><br>Here is a list of all possible vi_mode names used with the default color associated with them:

| Mode        | Description           | Value       |
| ----------- | --------------------- | ----------- |
| `NORMAL`    | Normal mode           | `'green'`   |
| `OP`        | Operator pending mode | `'green'`   |
| `INSERT`    | Insert mode           | `'red'`     |
| `VISUAL`    | Visual mode           | `'skyblue'` |
| `LINES`     | Visual lines mode     | `'skyblue'` |
| `BLOCK`     | Visual block mode     | `'skyblue'` |
| `REPLACE`   | Replace mode          | `'violet'`  |
| `V-REPLACE` | Virtual Replace mode  | `'violet'`  |
| `ENTER`     | Enter mode            | `'cyan'`    |
| `MORE`      | More mode             | `'cyan'`    |
| `SELECT`    | Select mode           | `'orange'`  |
| `COMMAND`   | Command mode          | `'green'`   |
| `SHELL`     | Shell mode            | `'green'`   |
| `TERM`      | Terminal mode         | `'green'`   |
| `NONE`      | None                  | `'yellow'`  |

#### Example configuration

Now that you know how to create Feline components, you can check out the code in the [default preset](lua/feline/presets/default.lua) to see how the components in it are set up so you can get a good practical idea of how to use the tools that Feline gives you.

### 3. Modifying an existing preset

If you like the defaults for the most part but there's some things you want to change, then you'd be glad to know that it's easy to just modify an existing preset to get the statusline configuration you want. Just do:

```lua
-- Substitute preset_name with the name of the preset you want to modify.
-- eg: "default" or "noicon"
local components = require('feline.presets')[preset_name].components
```

After that, you can just modify the components and call [the setup function](#the-setup-function) with the preset as you normally would.

## Providers

### Default providers

Feline by default has some built-in providers to make your life easy. They are:
|Name|Description|
--|--
|[`vi_mode`](#vi-mode)|Current vi_mode|
|`position`|Get line and column number of cursor|
|`line_percentage`|Current line percentage|
|`scroll_bar`|Scroll bar that shows file progress|
|[`file_info`](#file-info)|Get file icon, name and modified status|
|`file_size`|Get file size|
|`file_type`|Get file type|
|`file_encoding`|Get file encoding|
|[`git_branch`](#git)|Shows current git branch|
|[`git_diff_added`](#git)|Git diff added count|
|[`git_diff_removed`](#git)|Git diff removed count|
|[`git_diff_changed`](#git)|Git diff changed count|
|`lsp_client_names`|Name of LSP clients attached to current buffer|
|[`diagnostic_errors`](#diagnostics)|Diagnostics errors count|
|[`diagnostic_warnings`](#diagnostics)|Diagnostics warnings count|
|[`diagnostic_hints`](#diagnostics)|Diagnostics hints count|
|[`diagnostic_info`](#diagnostics)|Diagnostics info count|

#### Vi-mode

The vi-mode provider by itself only shows an icon. To actually indicate the current Vim mode, you have to use `require('feline.providers.vi_mode').get_mode_color()` for the component's `hl.fg`.

Note that this is different if you set the `icon` value of the component to `''`, in that case it'll use the name of the mode instead of an icon, which is what the `noicon` preset uses.

Here is the simplest method to make a component with proper Vi-mode indication:

```lua
-- Remember to change "components.active[1][1]" according to the rest of your config
components.active[1][1] = {
    provider = 'vi_mode',
    hl = function()
        return {
            name = require('feline.providers.vi_mode').get_mode_highlight_name(),
            fg = require('feline.providers.vi_mode').get_mode_color(),
            style = 'bold'
        }
    end,
    right_sep = ' ',
    -- Uncomment the next line to disable icons for this component and use the mode name instead
    -- icon = ''
}
```

The Vi-mode provider also provides a helper function `get_mode_highlight_name()` which can be used through `require('feline.providers.vi_mode').get_mode_highlight_name()`, it returns the highlight name for the current mode, which you can then use for the provider's `hl.name` to give its highlight groups meaningful names.

#### File Info

The `file_info` provider has some special component values:

- `colored_icon` (boolean): Determines whether file icon should use color inherited from `nvim-web-devicons`.<br>
Default: `true`
- `file_modified_icon` (string): The icon that is shown when a file is modified.<br>
Default:`'●'`
- `file_readonly_icon` (string): The icon that is shown when a file is read-only.<br>
Default:`'🔒'`
- `type` (string): Determines which parts of the filename are shown. Its value can be one of:
    - `'full-path'`: Full path of the file (eg: `'/home/user/.config/nvim/init.lua'`)
    - `'short-path'`: Shortened path of the file (eg: `'/h/u/.c/n/init.lua'`)
    - `'base-only'`: Show only base filename and extension (eg: `'init.lua'`)
    - `'relative'`: File path relative to the current directory.
    - `'relative-short'`: Combination of `'relative'` and `'short-path'`.
    - `'unique'`: Unique substring of the full path.<br>
    For example: If you have three buffers with the paths `'/home/user/file.lua'`, `'/home/user/dir1/file.lua'` and `'/home/user/dir2/file.lua'`, Feline will show the names `'user/file.lua'`, `'dir1/file.lua'` and `'dir2/file.lua'` for them, respectively.<br>
    If there's no files that share the same name, it behaves the same as `'base-only'`.
    - `'unique-short'`: Combination of `'unique'` and `'short-path'`.
    

    <br>Default: `'base-only'`

#### Git

The git providers all require [gitsigns.nvim](https://github.com/lewis6991/gitsigns.nvim/), make sure you have it installed when you use those providers, otherwise they'll have no output.

The git provider also provides a utility function `require('feline.providers.git').git_info_exists(winid)` (where `winid` is the window handler) for checking if any git information exists in the window through this utility function.

#### Diagnostics

The diagnostics and LSP providers all require the Neovim built-in LSP to be configured and at least one LSP client to be attached to the current buffer, else they'll have no output.

The diagnostics provider also provides a utility function `require('feline.providers.lsp').diagnostics_exist(type, winid)` (where `type` represents the type of diagnostic and `winid` is the window handler) for checking if any diagnostics of the provided type exists in the window. The values of `type` must be one of `'Error'`, `'Warning'`, `'Hint'` or `'Information'`.

### Adding your own provider

In case none of the default providers do what you want, it's very easy to add your own provider. Just call `require('feline.providers').add_provider(name, function)` where `name` is the name of the provider and `function` is the function associated with the provider, you can then use your provider the same way you use the other providers. Remember, the function has to take either no argument, or one argument that contains the component and its values.

## Help

### Common issues

#### Feline crashes or disappears for seemingly no reason

This can be caused if you forget to remove your other statusline plugins after installing Feline. Make sure all other statusline plugins are removed before you install Feline, that should fix the issue.

### Tips and tricks

#### Reset highlight

If, for some reason, you want to clear all highlights that Feline sets (useful if you want to reload your entire Neovim config which may mess up highlights), you can do:

```lua
require('feline').reset_highlights()
```

And then Feline will automatically regenerate those highlights when it needs them, so you don't have to worry about setting the highlights yourself.

#### Disable inactive statusline

If you want, you can just disable the inactive statusline by doing:

```lua
-- Remove all inactive statusline components
components.inactive = {}
```

Alternatively, you could also use a thin line instead of the inactive statusline to separate you windows, like the vertical split seperator, except in this case it would act as a horizontal separator of sorts. You can do this through:

```lua
local nvim_exec = vim.api.nvim_exec

-- Get highlight of inactive statusline by parsing the style, fg and bg of VertSplit
local InactiveStatusHL = {
    fg = nvim_exec("highlight VertSplit", true):match("guifg=(#[0-9A-Fa-f]+)") or "#444444",
    bg = nvim_exec("highlight VertSplit", true):match("guibg=(#[0-9A-Fa-f]+)") or "#1E1E1E",
    style = nvim_exec("highlight VertSplit", true):match("gui=(#[0-9A-Fa-f]+)") or "",
}

-- Add underline to inactive statusline highlight style
-- in order to have a thin line instead of the statusline
if InactiveStatusHL.style == '' then
    InactiveStatusHL.style = 'underline'
else
    InactiveStatusHL.style = InactiveStatusHL.style .. ',underline'
end

-- Apply the highlight to the statusline
-- by having an empty provider with the highlight
components.inactive = {
    {
        {
            provider = '',
            hl = InactiveStatusHL
        }
    }
}
```

### Reporting issues or feature requests

If you have an issue that you can't find the fix to in the documentation or want to request a feature you think is absolutely necessary, feel free to make a new [issue](https://github.com/famiu/feline.nvim/issues) and I will try my best to look into it.

## Why Feline?

Now, you might be thinking, why do we need another statusline plugin? We've already got a bunch of brilliant statusline plugins like galaxyline, airline, lualine, expressline etc. and all of them are excellent. So then, why Feline? What I'm about to say can be (and probably is) very biased and opinionated but, despite those plugins being neat, I think each have their own shortcomings, which I see as too much to ignore. Also I could be wrong about some of these things since I haven't used some of the plugins I'm about to mention.

Firstly, Feline is built for customizability from the ground up. You are not limited in any way by what the plugin provides. You can control every individual component and its location, appearance, everything about it. I find that all other plugins are very limited when it comes to customizability.

For example, Airline allows some customization through Vim's statusline syntax, which I find to be quite ugly and complicated. Lualine seems to give you little control over component separators, whereas Feline gives you complete control over what separator to use on what component, including the highlight of each separator. Feline also allows you to conditionally enable or disable components at any time, giving you complete control over your statusline.

Galaxyline is also a great plugin, I'd say it's much more customizable than the others I've mentioned. I used galaxyline before I created Feline and galaxyline is what inspired this plugin. But I think even galaxyline has its flaws. First and foremost, while I used galaxyline, I've found that it doesn't allow using the short statusline on components based on their buffer type or buffername, which meant I couldn't use the short line list on my terminal buffers. It also only allowed separator on one side of each component, making you resort to the separator of the previous or next component if you wanted separator on both sides, which caused all sorts of visual issues like the separator from the previous or next component being there even if the component you wanted the separator for is disabled.

Lastly, Feline only implements the bare minimum required for you to get started, and both expects and invites the user to make their own components and providers, because nobody understands you better than yourself. So my real intention is to make creating your own statusline as easy for you as possible, while also providing reasonable defaults that should be enough for most people.

And this plugin is named after cats, you won't get that anywhere else.

So yeah, those are the reasons to use Feline: minimalism, complete customizability, reasonable defaults, and cats.

## LICENSE

Feline is licensed under GNU GPLv3. For more info, see: [LICENSE.md](LICENSE.md).

## Miscellaneous

### Naming

The name of this plugin is a silly pun based on the convention of the names of statusline plugins ending with 'line', while also being named after cats. And in a way this statusline is supposed to be as quick as a cat's instincts, so I guess the name fits.

### Special thanks

[glepnir](https://github.com/glepnir) - for creating [galaxyline](https://github.com/glepnir/galaxyline.nvim) which this plugin was inspired by.

## Self-plug
If you liked this plugin, also check out:
- [bufdelete.nvim](https://github.com/famiu/bufdelete.nvim) - Delete Neovim buffers without losing your window layout.
