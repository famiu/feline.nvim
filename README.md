# feline.nvim

A minimal, stylish and customizable statusline for Neovim written in Lua

Requires Neovim >= 0.5

## About

Feline is a Lua statusline that prioritizes speed, customizability and minimalism. It's blazing fast and never gets in your way. Feline only provides you with the necessary tools that you need to customize the statusline to your liking and avoids feature-bloat. It's also extremely customizable and allows you to configure it in any way you wish to. Feline also has reasonable defaults for those who don't want to configure things and just want a good out of the box experience.

## Features

- Ease-of-use.
- Complete customizability over every component.
- [Built-in providers](#default-providers) such as:

  - Vi-mode
  - File info
  - Cursor position
  - Diagnostics (using [Neovim's built-in LSP](https://neovim.io/doc/user/lsp.html))
  - Git branch and diffs (using [gitsigns.nvim](https://github.com/lewis6991/gitsigns.nvim/))

  and many more

- Minimalistic, only provides the bare minimum and allows the user to build their own components very easily.

## Requirements

- Necessary
  - Neovim v0.5 or greater
  - You must have 24-bit RGB color enabled in Neovim (do `:help 'termguicolors'` in Neovim for more info)
- Optional
  - [nvim-web-devicons](https://github.com/kyazdani42/nvim-web-devicons/) - For icon support
  - [A patched font](https://github.com/ryanoasis/nerd-fonts/) - For icon support
  - [gitsigns.nvim](https://github.com/lewis6991/gitsigns.nvim/) - For [git providers](#git)

## Screenshots

**NOTE: Some of these configurations may be outdated and may need to be changed prior to use. A few of the configurations are missing a link because the link to them was removed due to the link no longer being valid.**

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

**[Config by iBhagwan:](https://github.com/ibhagwan/nvim-lua/blob/main/lua/plugins/feline.lua)**
![image](https://user-images.githubusercontent.com/59988195/133922136-3d037c37-7a3f-4e1b-b42e-c50b22fedfdb.png)

**[Config by EdenEast](https://github.com/EdenEast/nyx/blob/8a9819e/config/.config/nvim/lua/eden/modules/ui/feline/init.lua)** (Colors generated from applied colorscheme)

**Nightfox**
![image](https://user-images.githubusercontent.com/2746374/137549252-333f074e-47a0-464f-ac8a-7ce0ee43433c.png)

**Dayfox**
![image](https://user-images.githubusercontent.com/2746374/137549328-eb5f51c2-bd7b-4c9e-9080-b6132b688459.png)

You can add your own configuration to this list. If you're interested, simply make a [Pull Request](CONTRIBUTING.md) and I'll add it.

## Installation

- [packer.nvim](https://github.com/wbthomason/packer.nvim/):

```lua
use 'feline-nvim/feline.nvim'
```

- [vim-plug](https://github.com/junegunn/vim-plug/):

```vim
Plug 'feline-nvim/feline.nvim'
```

## Getting started

### Using the default configuration

Once you've installed Feline, it's extremely easy to get started with it. If you don't mind using the default settings, you can just call Feline's `setup()` function in your configuration. Like this:

```lua
require('feline').setup()
```

And that's it! It's as easy as that. In case you don't like icons and want to use the default statusline configuration but without icons, just do:

```lua
require('feline').setup({
    preset = 'noicon'
})
```

### Configuring Feline to fit your needs

If the default configuration doesn't fit your needs and you want to build your own statusline configuration, it's highly recommended to configure Feline to suit your needs. The only prerequisite is knowing the basics of Lua. Feline provides a ton of configuration options which can let you build your statusline exactly how you want it as long. To see how to do that, take a look at [USAGE](USAGE.md) or use `:help feline.txt` inside Neovim to read the USAGE documentation.

## Help

### Common issues

#### Feline crashes or disappears for seemingly no reason

This can be caused if you forget to remove your other statusline plugins after installing Feline. Make sure all other statusline plugins are removed before you install Feline, that should fix the issue.

### Reporting issues or feature requests

If you have an issue that you can't find the fix to in the documentation or want to request a feature you think is absolutely necessary, feel free to make a new [Issue](https://github.com/feline-nvim/feline.nvim/issues) and I will try my best to look into it. If you want to contribute to Feline, you can make a Pull Request. For more details, please see: [CONTRIBUTING](CONTRIBUTING.md)

## Why Feline?

Now, you might be thinking, why do we need another statusline plugin? We've already got a bunch of brilliant statusline plugins like galaxyline, airline, lualine, expressline etc. and all of them are excellent. So then, why Feline?

I'd like the preface this by saying that what I'm about to say can be (and probably is) very biased and opinionated. Take what's being said here with a grain of salt. All of this is purely my opinion and not a fact by any means, so it's fine to disagree. Moreover, any statement I make here may be incorrect or outdated. In which case, please feel free to make an [Issue or Pull Request](CONTRIBUTING.md) correcting it.

I think that despite those plugins being neat, each have their own shortcomings. I find those shortcomings as too much to ignore. For example, most of the statusline plugins are not very customizable and the plugins only provide a limited amount of tools and options for customization. Feline, on the other hand, is built for customizability from the ground up. You are not limited in any way by what the plugin provides. You can control every individual component and its location, appearance, everything about it.

Feline is also fast and never gets in your way. It lazy-loads most of its modules, which allows it to start up instantly. Statusline updates with Feline are also blazing fast, which provides for a really smooth experience.

Feline is minimal and only implements the bare minimum required for you to get started. It both expects and invites you to make your own components and providers, because nobody understands you better than yourself. To help you do that, Feline provides all the tools and options you would need while also giving you a solid foundation to build from. One could say that the real goal of Feline is to make creating your own statusline as easy for you as possible, while also providing reasonable defaults that should be enough for most people.

Documentation is another aspect where I found most statusline plugins to be very lacking. Feline is extremely easy to configure and well-documented, which allows anyone to be able to build their statusline as they wish to. It provides example for every option to allow anyone to easily understand the purpose of any option

Lastly, anyone is welcome to contribute to Feline, either by making an Issue or through a Pull Request (see [CONTRIBUTING](CONTRIBUTING.md) for further information). Any kind of contribution starting from fixing a minor typo to adding a massive new feature is welcome.

And this plugin is named after cats, you won't get that anywhere else.

## LICENSE

Feline is licensed under GNU GPLv3. For more info, see: [LICENSE.md](LICENSE.md).

## Miscellaneous

### Naming

The name of this plugin is a silly pun based on the convention of the names of statusline plugins ending with 'line', while also being named after cats. And in a way this statusline is supposed to be as quick as a cat's instincts, so I guess the name fits.

## Support
<a href="https://www.buymeacoffee.com/famiuhaque" target="_blank"><img src="https://cdn.buymeacoffee.com/buttons/v2/default-blue.png" alt="Buy Me A Coffee" style="height: 60px !important;width: 217px !important;" ></a>
