-- Default configuration options for Feline
-- Every configuration option can contain a few elements
-- `type` contains the name of the type of the configuration value
-- `default_value` contains the default value of the configuration
-- `update_default` determines if the custom configuration will update the default instead of
-- overriding it

return {
    colors = {
        type = 'table',
        update_default = true,
        default_value = {
            bg = '#1F1F23',
            black = '#1B1B1B',
            skyblue = '#50B0F0',
            cyan = '#009090',
            fg = '#D0D0D0',
            green = '#60A040',
            oceanblue = '#0066cc',
            magenta = '#C26BDB',
            orange = '#FF9000',
            red = '#D10000',
            violet = '#9E93E8',
            white = '#FFFFFF',
            yellow = '#E1E120'
        }
    },
    separators = {
        type = 'table',
        update_default = true,
        default_value = {
            vertical_bar = '┃',
            vertical_bar_thin = '│',
            left = '',
            right = '',
            block = '█',
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
        }
    },
    vi_mode_colors = {
        type = 'table',
        update_default = true,
        default_value = {
            ['NORMAL'] = 'green',
            ['OP'] = 'green',
            ['INSERT'] = 'red',
            ['VISUAL'] = 'skyblue',
            ['LINES'] = 'skyblue',
            ['BLOCK'] = 'skyblue',
            ['REPLACE'] = 'violet',
            ['V-REPLACE'] = 'violet',
            ['ENTER'] = 'cyan',
            ['MORE'] = 'cyan',
            ['SELECT'] = 'orange',
            ['COMMAND'] = 'green',
            ['SHELL'] = 'green',
            ['TERM'] = 'green',
            ['NONE'] = 'yellow'
        }
    },
    force_inactive = {
        type = 'table',
        default_value = {
            filetypes = {
                '^NvimTree$',
                '^packer$',
                '^startify$',
                '^fugitive$',
                '^fugitiveblame$',
                '^qf$',
                '^help$'
            },
            buftypes = {
                '^terminal$'
            }
        }
    },
    disable = {
        type = 'table',
        default_value = {}
    },
    highlight_reset_triggers = {
        type = 'table',
        default_value = {
            'SessionLoadPost',
            'ColorScheme'
        }
    },
    custom_providers = {
        type = 'table',
    },
    default_hl = {
        type = 'table',
        default_value = {}
    },
    components = {
        type = 'table'
    },
    preset = {
        type = 'string'
    }
}
