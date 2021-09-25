local bo = vim.bo
local api = vim.api

local feline = require('feline')
local providers = feline.providers
local components_table = feline.components
local default_hl = feline.default_hl
local colors = feline.colors
local separators = feline.separators
local disable = feline.disable
local force_inactive = feline.force_inactive

local strwidth = api.nvim_strwidth

local M = {
    highlights = {}
}

-- Return true if any pattern in tbl matches provided value
local function find_pattern_match(tbl, val)
    return next(vim.tbl_filter(function(pattern) return val:match(pattern) end, tbl))
end

-- Check if current buffer is forced to have inactive statusline
local function is_forced_inactive()
    local buftype = bo.buftype
    local filetype = bo.filetype
    local bufname = api.nvim_buf_get_name(0)

    return (force_inactive.filetypes and find_pattern_match(force_inactive.filetypes, filetype)) or
        (force_inactive.buftypes and find_pattern_match(force_inactive.buftypes, buftype)) or
        (force_inactive.bufnames and find_pattern_match(force_inactive.bufnames, bufname))
end

-- Check if buffer contained in window is configured to have statusline disabled
local function is_disabled(winid)
    local bufnr = api.nvim_win_get_buf(winid)

    local buftype = bo[bufnr].buftype
    local filetype = bo[bufnr].filetype
    local bufname = api.nvim_buf_get_name(bufnr)

    return (disable.filetypes and find_pattern_match(disable.filetypes, filetype)) or
        (disable.buftypes and find_pattern_match(disable.buftypes, buftype)) or
        (disable.bufnames and find_pattern_match(disable.bufnames, bufname))
end

-- Evaluate a component key if it is a function, else return the value
-- If the key is a function, every argument after the first one is passed to it
local function evaluate_if_function(key, ...)
    if type(key) == "function" then
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

-- Generates StatusLine and StatusLineNC highlights based on the user configuration
local function generate_defhl(winid)
    for statusline_type, hlname in pairs({active = 'StatusLine', inactive = 'StatusLineNC'}) do
        -- If default hl for the current statusline type is not defined, just set it to an empty
        -- table so that it can be populated by parse_hl later on
        if not default_hl[statusline_type] then
            default_hl[statusline_type] = {}
        end

        -- Only re-evaluate and add the highlight if it's a function or when it's not cached
        if type(default_hl[statusline_type]) == 'function' or not M.highlights[hlname] then
            local hl = parse_hl(evaluate_if_function(default_hl[statusline_type], winid))
            add_hl(hlname, hl.fg, hl.bg, hl.style)
        end
    end
end

-- Parse component seperator to return parsed string and length
-- By default, foreground color of separator is background color of parent
-- and background color is set to default background color
local function parse_sep(sep, parent_bg, is_component_empty)
    if sep == nil then return {str = '', len = 0} end

    local hl
    local str

    if type(sep) == 'string' then
        if is_component_empty then return {str = '', len = 0} end

        str = sep
        hl = {fg = parent_bg, bg = colors.bg}
    else
        if is_component_empty and not sep.always_visible then return {str = '', len = 0} end

        str = sep.str or ''
        hl = sep.hl or {fg = parent_bg, bg = colors.bg}
    end

    if separators[str] then str = separators[str] end

    return {
        str = string.format('%%#%s#%s', get_hlname(hl), str),
        len = strwidth(str)
    }
end

-- Either parse a single separator or a list of separators with different highlights
local function parse_sep_list(sep_list, parent_bg, is_component_empty, winid)
    if sep_list == nil then return {str = '', len = 0} end

    if (type(sep_list) == 'table' and sep_list[1] and (type(sep_list[1]) == 'function' or
    type(sep_list[1]) == 'table' or type(sep_list[1]) == 'string')) then
        local sep_strs = {}
        local total_len = 0

        for _,v in ipairs(sep_list) do
            local sep = parse_sep(
                evaluate_if_function(v, winid),
                parent_bg,
                is_component_empty
            )

            sep_strs[#sep_strs+1] = sep.str
            total_len = total_len + sep.len
        end

        return {str = table.concat(sep_strs), len = total_len}
    else
        return parse_sep(evaluate_if_function(sep_list, winid), parent_bg, is_component_empty)
    end
end

-- Parse component icon and return parsed string alongside length
-- By default, icon inherits component highlights
local function parse_icon(icon, parent_hl, is_component_empty)
    if icon == nil then return {str = '', len = 0} end

    local hl
    local str

    if type(icon) == 'string' then
        if is_component_empty then return {str = '', len = 0} end

        str = icon
        hl = parent_hl
    else
        if is_component_empty and not icon.always_visible then return {str = '', len = 0} end

        str = icon.str or ''
        hl = icon.hl or parent_hl
    end

    return {
        str = string.format('%%#%s#%s', get_hlname(hl, parent_hl), str),
        len = strwidth(str)
    }
end

-- Parse component provider to return the provider string, icon and length of provider string
local function parse_provider(provider, winid, component)
    local icon

    -- If provider is a string and its name matches the name of a registered provider, use it
    if type(provider) == 'string' and providers[provider] then
        provider, icon = providers[provider](winid, component, {})
    -- If provider is a function, just evaluate it normally
    elseif type(provider) == 'function' then
        provider, icon = provider(winid, component)
    -- If provider is a table, get the provider name and opts and evaluate the provider
    elseif type(provider) == 'table' then
        provider, icon = providers[provider.name](winid, component, provider.opts or {})
    end

    if type(provider) ~= 'string' then
        api.nvim_err_writeln(string.format(
            "Provider must evaluate to string, got type '%s' instead",
            type(provider)
        ))
    end

    return {str = provider, len = strwidth(provider)}, icon
end

-- Parses a component alongside its highlight to return the component string and length
local function parse_component(component, winid, use_short_provider)
    local enabled

    if component.enabled then enabled = component.enabled else enabled = true end

    enabled = evaluate_if_function(enabled, winid)

    if not enabled then return {str = '', len = 0} end

    local hl = evaluate_if_function(component.hl, winid) or {}
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

    local provider, icon

    if use_short_provider then
        provider = component.short_provider
    else
        provider = component.provider
    end

    if provider then
        provider, icon = parse_provider(provider, winid, component)
    else
        provider = {str = '', len = 0}
    end

    local is_component_empty = provider.str == ''

    local left_sep = parse_sep_list(
        component.left_sep,
        hl.bg,
        is_component_empty,
        winid
    )

    local right_sep = parse_sep_list(
        component.right_sep,
        hl.bg,
        is_component_empty,
        winid
    )

    icon = parse_icon(
        evaluate_if_function(component.icon or icon, winid),
        hl,
        is_component_empty
    )

    return {
        str = string.format(
            '%s%s%%#%s#%s%s',
            left_sep.str,
            icon.str,
            hlname or get_hlname(hl),
            provider.str,
            right_sep.str
        ),
        len = left_sep.len + icon.len + provider.len + right_sep.len
    }
end

-- Generate statusline by parsing all components and return a string
function M.generate_statusline(winid)
    -- Generate default highlights for the statusline
    generate_defhl(winid)

    local statusline_str = ''

    if components_table and not is_disabled(winid) then
        local statusline_type

        if winid == api.nvim_get_current_win() and not is_forced_inactive() then
            statusline_type='active'
        else
            statusline_type='inactive'
        end

        local sections = components_table[statusline_type]

        -- Parse all components in the sections and also store the indices of every component so
        -- both the sections and parsed_sections tables can be accessed later on after components
        -- are sorted in order of priority
        -- Also calculate statusline length while doing all of that
        local parsed_sections = {}
        local component_indices = {}
        local statusline_length = 0

        for i, section in ipairs(sections) do
            parsed_sections[i] = {}

            for j, component in ipairs(section) do
                local ok, result = pcall(parse_component, component, winid)

                if not ok then
                    api.nvim_err_writeln(string.format(
                        "Feline: error while processing component number %d on section %d "..
                        "of type '%s': %s",
                        j, i, statusline_type, result
                    ))

                    result = { str = '', len = 0 }
                end

                parsed_sections[i][j] = result
                component_indices[#component_indices+1] = {i, j}
                statusline_length = statusline_length + result.len
            end
        end

        local win_width = api.nvim_win_get_width(winid)

        -- If statusline length is larger than the window width, sort the component indices
        -- in ascending order of priority of the components they refer to
        -- Then truncate the components one by one using by their short_provider or hiding them
        -- entirely until the statusline fits within the window
        if statusline_length > win_width then
            table.sort(component_indices, function(a, b)
                -- Access the original component through the sections table using the indices
                local first_component_priority = sections[a[1]][a[2]].priority or 0
                local second_component_priority = sections[b[1]][b[2]].priority or 0

                return first_component_priority < second_component_priority
            end)

            for _, indices in ipairs(component_indices) do
                -- Access the original and parsed values using the indices
                local component = sections[indices[1]][indices[2]]
                local parsed_component = parsed_sections[indices[1]][indices[2]]

                -- If short_provider exists, use it
                if component.short_provider then
                    -- Get new parsed component value using the short_provider and calculate the
                    -- length difference between the two values, and if it's greater than 0, use
                    -- the new value instead of the old one
                    local parsed_component_new = parse_component(component, winid, true)
                    local length_difference = parsed_component.len - parsed_component_new.len

                    if length_difference > 0 then
                        -- Update statusline length and replace old parsed value with new one
                        statusline_length = statusline_length - length_difference
                        parsed_sections[indices[1]][indices[2]] = parsed_component_new
                    end
                end

                if statusline_length <= win_width then break end
            end

            -- If statusline still doesn't fit, start removing components with truncate_hide
            if statusline_length > win_width then
                for _, indices in ipairs(component_indices) do
                    if sections[indices[1]][indices[2]].truncate_hide then
                        statusline_length = statusline_length -
                            parsed_sections[indices[1]][indices[2]].len

                        parsed_sections[indices[1]][indices[2]] = {str = '', len = 0}
                    end

                    if statusline_length <= win_width then break end
                end
            end
        end

        -- Concatenate all components in each section to get a string for each section
        local section_strs = {}

        for i, parsed_section in ipairs(parsed_sections) do
            local component_strs = {}

            for j, parsed_component in ipairs(parsed_section) do
                component_strs[j] = parsed_component.str
            end

            section_strs[i] = table.concat(component_strs)
        end

        -- Finally, concatenate all sections to get the statusline string
        statusline_str = table.concat(section_strs, '%=')
    end

    -- Never return an empty string since setting statusline to an empty string will make it
    -- use the global statusline value (same as active statusline) for inactive windows
    if statusline_str == '' then
        return ' '
    else
        return statusline_str
    end
end

return M
