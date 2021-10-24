local bo = vim.bo
local api = vim.api

local feline = require('feline')
local providers = feline.providers
local colors = feline.colors
local separators = feline.separators

local M = {
    -- Cached highlights
    highlights = {}
}

-- Return true if any pattern in tbl matches provided value
local function find_pattern_match(tbl, val)
    return next(vim.tbl_filter(function(pattern) return val:match(pattern) end, tbl))
end

-- Check if current buffer is forced to have inactive statusline
local function is_forced_inactive()
    local force_inactive = feline.force_inactive
    local buftype = bo.buftype
    local filetype = bo.filetype
    local bufname = api.nvim_buf_get_name(0)

    return (force_inactive.filetypes and find_pattern_match(force_inactive.filetypes, filetype)) or
        (force_inactive.buftypes and find_pattern_match(force_inactive.buftypes, buftype)) or
        (force_inactive.bufnames and find_pattern_match(force_inactive.bufnames, bufname))
end

-- Check if buffer is configured to have statusline disabled
local function is_disabled()
    local disable = feline.disable
    local buftype = bo.buftype
    local filetype = bo.filetype
    local bufname = api.nvim_buf_get_name(0)

    return (disable.filetypes and find_pattern_match(disable.filetypes, filetype)) or
        (disable.buftypes and find_pattern_match(disable.buftypes, buftype)) or
        (disable.bufnames and find_pattern_match(disable.bufnames, bufname))
end

-- Evaluate a component key if it is a function, else return the value
-- If the key is a function, every argument after the first one is passed to it
local function evaluate_if_function(key, ...)
    if type(key) == 'function' then
        return key(...)
    else
        return key
    end
end

-- Add highlight and store its name in the highlights table
local function add_hl(name, fg, bg, style)
    api.nvim_command(string.format(
        'highlight %s gui=%s guifg=%s guibg=%s',
        name,
        style,
        fg,
        bg
    ))

    M.highlights[name] = true
end

-- Parse highlight table, inherit default/parent values if values are not given
local function parse_hl(hl, parent_hl)
    parent_hl = parent_hl or {}

    hl.fg = hl.fg or parent_hl.fg or colors.fg
    hl.bg = hl.bg or parent_hl.bg or colors.bg
    hl.style = hl.style or parent_hl.style or 'NONE'

    if colors[hl.fg] then hl.fg = colors[hl.fg] end
    if colors[hl.bg] then hl.bg = colors[hl.bg] end

    return hl
end

-- If highlight is a string, use it as highlight name and
-- extract the properties from the highlight
local function get_hl_properties(hlname)
    local hl = api.nvim_get_hl_by_name(hlname, true)
    local styles = {}

    for k, v in ipairs(hl) do
        if v == true then
            styles[#styles+1] = k
        end
    end

    return {
        name = hlname,
        fg = hl.foreground and string.format('#%06x', hl.foreground),
        bg = hl.background and string.format('#%06x', hl.background),
        style = next(styles) and table.concat(styles, ',') or 'NONE'
    }
end

-- Generate unique name for highlight if name is not given
-- Create the highlight with the name if it doesn't exist
-- If given a string, just interpret it as an external highlight group and return it
local function get_hlname(hl, parent_hl)
    if type(hl) == 'string' then return hl end

    -- If highlight name exists and is cached, just return it
    if hl.name and M.highlights[hl.name] then
        return hl.name
    end

    hl = parse_hl(hl, parent_hl)

    local fg_str, bg_str

    -- If first character of the color starts with '#', remove the '#' and keep the rest
    -- If it doesn't start with '#', do nothing
    if hl.fg:sub(1, 1) == '#' then fg_str = hl.fg:sub(2) else fg_str = hl.fg end
    if hl.bg:sub(1, 1) == '#' then bg_str = hl.bg:sub(2) else bg_str = hl.bg end

    -- Generate unique hl name from color strings if a name isn't provided
    local hlname = hl.name or string.format(
        'StatusComponent_%s_%s_%s',
        fg_str,
        bg_str,
        string.gsub(hl.style, ',', '_')
    )

    if not M.highlights[hlname] then
        add_hl(hlname, hl.fg, hl.bg, hl.style)
    end

    return hlname
end

-- Parse component seperator to return parsed string
-- By default, foreground color of separator is background color of parent
-- and background color is set to default background color
local function parse_sep(sep, parent_bg, is_component_empty)
    if sep == nil then return '' end

    sep = evaluate_if_function(sep)

    local hl
    local str

    if type(sep) == 'string' then
        if is_component_empty then return '' end

        str = sep
        hl = {fg = parent_bg, bg = colors.bg}
    else
        if is_component_empty and not sep.always_visible then return '' end

        str = evaluate_if_function(sep.str) or ''
        hl = evaluate_if_function(sep.hl) or {fg = parent_bg, bg = colors.bg}
    end

    if separators[str] then str = separators[str] end

    return string.format('%%#%s#%s', get_hlname(hl), str)
end

-- Either parse a single separator or a list of separators returning the parsed string
local function parse_sep_list(sep_list, parent_bg, is_component_empty)
    if sep_list == nil then return '' end

    if (type(sep_list) == 'table' and sep_list[1] and (
        type(sep_list[1]) == 'function' or
        type(sep_list[1]) == 'table' or
        type(sep_list[1]) == 'string'
    )) then
        local sep_strs = {}

        for _,v in ipairs(sep_list) do
            sep_strs[#sep_strs+1] = parse_sep(
                v,
                parent_bg,
                is_component_empty
            )
        end

        return table.concat(sep_strs)
    else
        return parse_sep(sep_list, parent_bg, is_component_empty)
    end
end

-- Parse component icon and return parsed string
-- By default, icon inherits component highlights
local function parse_icon(icon, parent_hl, is_component_empty)
    if icon == nil then return '' end

    icon = evaluate_if_function(icon)

    local hl
    local str

    if type(icon) == 'string' then
        if is_component_empty then return '' end

        str = icon
        hl = parent_hl
    else
        if is_component_empty and not icon.always_visible then return '' end

        str = evaluate_if_function(icon.str) or ''
        hl = evaluate_if_function(icon.hl) or parent_hl
    end

    return string.format('%%#%s#%s', get_hlname(hl, parent_hl), str)
end

-- Parse component provider to return the provider string and default icon
local function parse_provider(provider, component)
    local str = ''
    local icon

    -- If provider is a string and its name matches the name of a registered provider, use it
    if type(provider) == 'string' then
        if providers[provider] then
            str, icon = providers[provider](component, {})
        else
            str = provider
        end
    -- If provider is a function, just evaluate it normally
    elseif type(provider) == 'function' then
        str, icon = provider(component)
    -- If provider is a table, get the provider name and opts and evaluate the provider
    elseif type(provider) == 'table' then
        if not provider.name then
            api.nvim_err_writeln("Provider table doesn't have the provider name")
        elseif type(provider.name) ~= 'string' then
            api.nvim_err_writeln(string.format(
                "Expected 'string' for provider name, got '%s' instead",
                type(provider.name)
            ))
        elseif not providers[provider.name] then
            api.nvim_err_writeln(string.format(
                "Provider with name '%s' doesn't exist",
                provider.name
            ))
        else
            str, icon = providers[provider.name](component, provider.opts or {})
        end
    end

    if type(str) ~= 'string' then
        api.nvim_err_writeln(string.format(
            "Provider must evaluate to string, got type '%s' instead",
            type(provider)
        ))

        str = ''
    end

    return str, icon
end

local function parse_component(component, use_short_provider)
    local enabled

    if component.enabled ~= nil then
        enabled = evaluate_if_function(component.enabled)
    else
        enabled = true
    end

    if not enabled then return '' end

    local hl = evaluate_if_function(component.hl) or {}
    local hlname

    -- If highlight is a string, then accept it as an external highlight group and
    -- extract its properties for use as a parent highlight for separators and icon
    if type(hl) == 'string' then
        hlname = hl
        hl = get_hl_properties(hl)
    -- If highlight is a table, parse the highlight so it can be passed to
    -- parse_sep_list and parse_icon
    else
        hl = parse_hl(hl)
    end

    local provider, str, icon

    if use_short_provider then
        provider = component.short_provider
    else
        provider = component.provider
    end

    if provider then
        str, icon = parse_provider(provider, component)
    else
        str = ''
    end

    local is_component_empty = str == ''

    local left_sep_str = parse_sep_list(
        component.left_sep,
        hl.bg,
        is_component_empty
    )

    local right_sep_str = parse_sep_list(
        component.right_sep,
        hl.bg,
        is_component_empty
    )

    icon = parse_icon(
        component.icon or icon,
        hl,
        is_component_empty
    )

    return string.format(
        '%s%s%%#%s#%s%s',
        left_sep_str,
        icon,
        hlname or get_hlname(hl),
        str,
        right_sep_str
    )
end

-- Wrapper around parse_component that handles any errors that happen while parsing the components
-- and points to the location of the component in case of any errors
local function parse_component_handle_errors(
    component,
    use_short_provider,
    statusline_type,
    component_section,
    component_number
)
    local ok, result = pcall(parse_component, component, use_short_provider)

    if not ok then
        api.nvim_err_writeln(string.format(
            "Feline: error while processing component number %d on section %d of type '%s': %s",
            component_number,
            component_section,
            statusline_type,
            result
        ))

        return ''
    end

    return result
end

-- Prevent reinitializing the options table everytime `nvim_eval_statusline` is called
local eval_statusline_opts = { maxwidth = 0 }

local function get_component_width(component_str)
    if not api.nvim_eval_statusline then
        return 0
    end

    return api.nvim_eval_statusline(component_str, eval_statusline_opts).width
end

-- Generate statusline by parsing all components and return a string
function M.generate_statusline(is_active)
    local components_table = feline.components

    if not components_table or is_disabled() then
        return ''
    end

    local statusline_type

    if is_active and not is_forced_inactive() then
        statusline_type='active'
    else
        statusline_type='inactive'
    end

    local sections = components_table[statusline_type]

    if not sections then
        return ''
    end

    -- Iterate through all the components, parse them and store the component strings, each
    -- component's indices and width in separate tables, while also calculating the statusline width
    local component_strs = {}
    local component_indices = {}
    local component_widths = {}
    local statusline_width = 0

    for i, section in ipairs(sections) do
        component_strs[i] = {}
        component_widths[i] = {}

        for j, component in ipairs(section) do
            local component_str = parse_component_handle_errors(
                component, false, statusline_type, i, j
            )

            local component_width = get_component_width(component_str)

            component_strs[i][j] = component_str
            component_widths[i][j] = component_width
            statusline_width = statusline_width + component_width

            component_indices[#component_indices+1] = {i, j}
        end
    end

    local window_width = api.nvim_win_get_width(0)

    -- If statusline width is greater than the window width, begin the truncation process
    if statusline_width > window_width then
        -- First, sort the component indices in ascending order of the priority of the components
        -- that the indices refer to
        table.sort(component_indices, function(first, second)
            local first_priority = sections[first[1]][first[2]].priority or 0
            local second_priority = sections[second[1]][second[2]].priority or 0

            return first_priority < second_priority
        end)

        -- Then, iterate through the sorted indices to access the components in order of priority,
        -- and if the component has a short_provider, use it instead of the normal provider to
        -- truncate the component
        for _, indices in ipairs(component_indices) do
            local section, number = indices[1], indices[2]
            local component = sections[section][number]

            if component.short_provider then
                local component_str = parse_component_handle_errors(
                    component, true, statusline_type, section, number
                )

                local component_width = get_component_width(component_str)

                -- Calculate how much the width of the statusline decreases if the provider is
                -- replaced with the short_provider, and if it's greater than 0 (which implies that
                -- the statusline decreased in width), replace the provider with the short_provider
                -- and update the statusline_width variable to reflect the change
                local width_difference = component_widths[section][number] - component_width

                if width_difference > 0 then
                    statusline_width = statusline_width - width_difference
                    component_strs[section][number] = component_str
                    component_widths[section][number] = component_width
                end
            end

            if statusline_width <= window_width then break end
        end
    end

    -- If statusline still doesn't fit within window, remove components with truncate_hide set to
    -- true until it does
    if statusline_width > window_width then
        for _, indices in ipairs(component_indices) do
            local section, number = indices[1], indices[2]

            if sections[section][number].truncate_hide then
                statusline_width = statusline_width - component_widths[section][number]
                component_strs[section][number] = ''
                component_widths[section][number] = 0
            end

            if statusline_width <= window_width then break end
        end
    end

    -- Concatenate all component strings in each section to get a string for each section
    local section_strs = {}

    for i, section_component_strs in ipairs(component_strs) do
        section_strs[i] = table.concat(section_component_strs)
    end

    -- Finally, concatenate all sections to get the statusline string, and return it
    return table.concat(section_strs, '%=')
end

return M
