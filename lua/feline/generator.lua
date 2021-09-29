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

-- Parse component seperator
-- By default, foreground color of separator is background color of parent
-- and background color is set to default background color
local function parse_sep(sep, parent_bg, is_component_empty, winid)
    if sep == nil then return '' end

    sep = evaluate_if_function(sep, winid)

    local hl
    local str

    if type(sep) == 'string' then
        if is_component_empty then return '' end

        str = sep
        hl = {fg = parent_bg, bg = colors.bg}
    else
        if is_component_empty and not sep.always_visible then return '' end

        str = evaluate_if_function(sep.str, winid) or ''
        hl = evaluate_if_function(sep.hl, winid) or {fg = parent_bg, bg = colors.bg}
    end

    if separators[str] then str = separators[str] end

    return string.format('%%#%s#%s', get_hlname(hl), str)
end

-- Either parse a single separator or a list of separators
local function parse_sep_list(sep_list, parent_bg, is_component_empty, winid)
    if sep_list == nil then return '' end

    if (type(sep_list) == 'table' and sep_list[1] and (type(sep_list[1]) == 'function' or
    type(sep_list[1]) == 'table' or type(sep_list[1]) == 'string')) then
        local sep_strs = {}

        for _,v in ipairs(sep_list) do
            sep_strs[#sep_strs+1] = parse_sep(
                v,
                parent_bg,
                is_component_empty,
                winid
            )
        end

        return table.concat(sep_strs)
    else
        return parse_sep(sep_list, parent_bg, is_component_empty, winid)
    end
end

-- Parse component icon
-- By default, icon inherits component highlights
local function parse_icon(icon, parent_hl, is_component_empty, winid)
    if icon == nil then return '' end

    icon = evaluate_if_function(icon, winid)

    local hl
    local str

    if type(icon) == 'string' then
        if is_component_empty then return '' end

        str = icon
        hl = parent_hl
    else
        if is_component_empty and not icon.always_visible then return '' end

        str = evaluate_if_function(icon.str, winid) or ''
        hl = evaluate_if_function(icon.hl, winid) or parent_hl
    end

    return string.format('%%#%s#%s', get_hlname(hl, parent_hl), str)
end

-- Parse component provider to return the provider string and icon
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

    return provider, icon
end

-- Parses a component to return a Vim statusline string that can be displayed in the statusline
local function parse_component(component, winid, use_short_provider)
    local enabled

    if component.enabled then enabled = component.enabled else enabled = true end

    enabled = evaluate_if_function(enabled, winid)

    if not enabled then return '' end

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
        provider = ''
    end

    local is_component_empty = provider == ''

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
        component.icon or icon,
        hl,
        is_component_empty,
        winid
    )

    return string.format(
        '%s%s%%#%s#%s%s',
        left_sep,
        icon,
        hlname or get_hlname(hl),
        provider,
        right_sep
    )
end

-- Parse component and return component string, catching all errors and providing the component
-- type, section and number in case of an error to make the configuration easier to debug
local function get_component_str(component, winid, use_short_provider, type, section, number)
    local ok, result = pcall(parse_component, component, winid, use_short_provider)

    if not ok then
        api.nvim_err_writeln(string.format(
            "Feline: error while processing component number %d on section %d " ..
            "of type '%s': %s",
            number, section, type, result
        ))

        result = ''
    end

    return result
end

-- Get display width of Vim statusline string by ignoring the characters that will not be displayed
local function get_statusline_str_length(statusline_str)
    local length = 0
    local i = 1

    -- Since the statusline can contain Unicode characters, the # operator only gives the
    -- amount of bytes in the statusline string, not the actual amount of characters
    local statusline_str_bytecount = #statusline_str

    -- Get UTF-32 character in index `i` from statusline string
    local function getchar()
        if i <= statusline_str_bytecount then
            -- Find the utfindex of the character that contains the current byte
            -- Then use it to find the index of the last byte of the UTF-32 character
            local utfindex = vim.str_utfindex(statusline_str, i)
            local byteindex_end = vim.str_byteindex(statusline_str, utfindex)

            -- Get UTF-32 character by making a substring of the string starting from i to the last
            -- byte of the character
            local char = statusline_str:sub(i, byteindex_end)

            -- Put the index one character after the end of the last byte of the current character
            i = byteindex_end + 1

            return char
        end
    end

    repeat
        local char = getchar()

        -- If character is '%', treat it as a statusline modifiers
        if char == '%' then
            char = getchar()

            -- Treat characters inside %# as highlight names and ignore them
            if char == '#' then
                while char do
                    char = getchar()

                    if char == '#' then
                        break
                    end
                end
            -- Treat %% as a literal % character
            elseif char == '%' then
                length = length + 1
            end
        -- If it's not a statusline modifier and isn't nil, treat it like a normal character
        elseif char ~= nil then
            -- It's not correct to just append 1 to the length since the character can be
            -- multi-width, instead find out the width of the character and append that instead
            length = length + strwidth(char)
        end
    until char == nil

    return length
end

-- Parse statusline sections and truncate the components when necessary
local function parse_statusline_sections(sections, statusline_type, winid)
    -- Table containing parsed strings for every component
    local component_strs = {}
    -- Table containing the display length of every component
    local component_lengths = {}
    -- Table storing all of the component indices which will later be sorted in ascending order of
    -- component priority and be used to iterate through the components in that order
    local component_indices = {}
    -- Total length of statusline
    local statusline_length = 0

    -- Populate the tables defined above and calculate the statusline length
    for i, section in ipairs(sections) do
        component_strs[i] = {}
        component_lengths[i] = {}

        for j, component in ipairs(section) do
            local component_str = get_component_str(component, winid, false, statusline_type, i, j)
            local component_len = get_statusline_str_length(component_str)

            component_strs[i][j] = component_str
            component_lengths[i][j] = component_len
            component_indices[#component_indices+1] = {i, j}
            statusline_length = statusline_length + component_len
        end
    end

    local win_width = api.nvim_win_get_width(winid)

    -- If statusline length is greater than window width, proceed with truncation
    if statusline_length > win_width then
        -- Sort the component indices in ascending order of priority of the components that the
        -- indices refer to
        table.sort(component_indices, function(a, b)
            -- Access the priority of the components using the indices
            local first_component_priority = sections[a[1]][a[2]].priority or 0
            local second_component_priority = sections[b[1]][b[2]].priority or 0

            return first_component_priority < second_component_priority
        end)

        -- Iterate through every component in ascending order of priority using the indices
        -- and keep truncating components until statusline fits within window
        for _, indices in ipairs(component_indices) do
            local i, j = unpack(indices)

            -- If component has a short provider, use it to truncate the component
            if sections[i][j].short_provider then
                local new_component_str =
                    get_component_str(sections[i][j], winid, true, statusline_type, i, j)
                local new_component_len = get_statusline_str_length(new_component_str)
                local length_difference = component_lengths[i][j] - new_component_len

                if length_difference > 0 then
                    statusline_length = statusline_length - length_difference
                    component_strs[i][j] = new_component_str
                    component_lengths[i][j] = new_component_len
                end
            end

            if statusline_length <= win_width then break end
        end

        -- If statusline still doesn't fit within window, then remove the components with
        -- truncate_hide set to true
        if statusline_length > win_width then
            for _, indices in ipairs(component_indices) do
                local i, j = unpack(indices)

                if sections[i][j].truncate_hide then
                    statusline_length = statusline_length - component_lengths[i][j]
                    component_strs[i][j] = ''
                    component_lengths[i][j] = 0
                end

                if statusline_length <= win_width then break end
            end
        end
    end

    -- Concatenate components of every section to get a string for each section
    local section_strs = {}

    for i, section_components in ipairs(component_strs) do
        section_strs[i] = table.concat(section_components)
    end

    -- Finally, concatenate the sections to get the statusline string and return it
    return table.concat(section_strs, '%=')
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

        if sections then
            statusline_str = parse_statusline_sections(sections, statusline_type, winid)
        end
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
