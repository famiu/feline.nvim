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
    local styles_len = 1

    for k, v in ipairs(hl) do
        if v == true then
            styles[styles_len] = k
            styles_len = styles_len + 1
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
local function parse_sep(sep, parent_bg, is_component_empty, winid)
    if sep == nil then return '', 0 end

    sep = evaluate_if_function(sep, winid)

    local hl
    local str

    if type(sep) == 'string' then
        if is_component_empty then return '', 0 end

        str = sep
        hl = {fg = parent_bg, bg = colors.bg}
    else
        if is_component_empty and not sep.always_visible then return '', 0 end

        str = evaluate_if_function(sep.str, winid) or ''
        hl = evaluate_if_function(sep.hl, winid) or {fg = parent_bg, bg = colors.bg}
    end

    if separators[str] then str = separators[str] end

    return string.format('%%#%s#%s', get_hlname(hl), str), strwidth(str)
end

-- Either parse a single separator or a list of separators returning the parsed string alongside the
-- display length of the string
local function parse_sep_list(sep_list, parent_bg, is_component_empty, winid)
    if sep_list == nil then return '', 0 end

    if (type(sep_list) == 'table' and sep_list[1] and (type(sep_list[1]) == 'function' or
    type(sep_list[1]) == 'table' or type(sep_list[1]) == 'string')) then
        local sep_strs = {}
        local sep_strs_len = 1
        local total_len = 0

        for _,v in ipairs(sep_list) do
            local sep_str, sep_len = parse_sep(
                v,
                parent_bg,
                is_component_empty,
                winid
            )

            sep_strs[sep_strs_len] = sep_str
            sep_strs_len = sep_strs_len + 1
            total_len = total_len + sep_len
        end

        return table.concat(sep_strs), total_len
    else
        return parse_sep(sep_list, parent_bg, is_component_empty, winid)
    end
end

-- Parse component icon and return parsed string alongside length
-- By default, icon inherits component highlights
local function parse_icon(icon, parent_hl, is_component_empty, winid)
    if icon == nil then return '', 0 end

    icon = evaluate_if_function(icon, winid)

    local hl
    local str

    if type(icon) == 'string' then
        if is_component_empty then return '', 0 end

        str = icon
        hl = parent_hl
    else
        if is_component_empty and not icon.always_visible then return '', 0 end

        str = evaluate_if_function(icon.str, winid) or ''
        hl = evaluate_if_function(icon.hl, winid) or parent_hl
    end

    return string.format('%%#%s#%s', get_hlname(hl, parent_hl), str), strwidth(str)
end

-- Parse component provider to return the provider string, provider length and default icon
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

    return provider, strwidth(provider), icon
end

-- Parses a component alongside its highlight to return the component string and length
local function parse_component(component, winid, use_short_provider)
    local enabled

    if component.enabled then enabled = component.enabled else enabled = true end

    enabled = evaluate_if_function(enabled, winid)

    if not enabled then return '', 0 end

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

    local provider, provider_len, icon, icon_len

    if use_short_provider then
        provider = component.short_provider
    else
        provider = component.provider
    end

    if provider then
        provider, provider_len, icon = parse_provider(provider, winid, component)
    else
        provider, provider_len = '', 0
    end

    local is_component_empty = provider == ''

    local left_sep_str, left_sep_len = parse_sep_list(
        component.left_sep,
        hl.bg,
        is_component_empty,
        winid
    )

    local right_sep_str, right_sep_len = parse_sep_list(
        component.right_sep,
        hl.bg,
        is_component_empty,
        winid
    )

    icon, icon_len = parse_icon(
        component.icon or icon,
        hl,
        is_component_empty,
        winid
    )

    return string.format(
            '%s%s%%#%s#%s%s',
            left_sep_str,
            icon,
            hlname or get_hlname(hl),
            provider,
            right_sep_str
        ),
        left_sep_len + icon_len + provider_len + right_sep_len
end

-- Parse component while handling any errors and returning an empty component in case of an error
local function parse_component_handle_errors(
    component,
    winid,
    use_short_provider,
    statusline_type,
    section_number,
    component_number
)
    local ok, str, str_len = pcall(parse_component, component, winid, use_short_provider)

    if not ok then
        api.nvim_err_writeln(string.format(
            "Feline: error while processing component number %d on section %d of type '%s': %s",
            component_number, section_number, statusline_type, str
        ))

        str, str_len = '', 0
    end

    return str, str_len
end

-- Parse statusline sections and truncate the components when necessary
local function parse_statusline_sections(sections, statusline_type, winid)
    local component_strs = {}
    local component_lengths = {}
    local statusline_length = 0

    -- Parse every component, storing their value and length in separate tables and calculate
    -- statusline length while doing that
    for i, section in ipairs(sections) do
        component_strs[i] = {}
        component_lengths[i] = {}

        for j, component in ipairs(section) do
            component_strs[i][j], component_lengths[i][j] = parse_component_handle_errors(
                component, winid, false, statusline_type, i, j
            )

            statusline_length = statusline_length + component_lengths[i][j]
        end
    end

    -- Get window width
    local win_width = api.nvim_win_get_width(winid)

    -- If statusline doesn't fit within window, start the truncation process
    if statusline_length > win_width then
        -- Get all component indices so they can be sorted in ascending order of priority
        local component_indices = {}
        local component_indices_len = 0

        for i, section in ipairs(sections) do
            for j, _ in ipairs(section) do
                component_indices_len = component_indices_len + 1
                component_indices[component_indices_len] = {i, j}
            end
        end

        -- Sort component indices in ascending order of priority of the components they refer to
        table.sort(component_indices, function(a, b)
            -- Get the priority of each component by accessing the sections table using the indices
            -- Use the default priority of 0 if priority isn't defined
            local a_priority = sections[a[1]][a[2]].priority or 0
            local b_priority = sections[b[1]][b[2]].priority or 0

            return a_priority < b_priority
        end)

        -- Iterate the components in order of priority using the sorted indices and truncate them
        -- using the short_provider until the statusline fits within the window
        for _, indices in ipairs(component_indices) do
            local i, j = unpack(indices)

            if sections[i][j].short_provider then
                local str, len = parse_component_handle_errors(
                    sections[i][j], winid, true, statusline_type, i, j
                )

                local length_difference = component_lengths[i][j] - len

                if length_difference > 0 then
                    statusline_length = statusline_length - length_difference
                    component_strs[i][j] = str
                    component_lengths[i][j] = len
                end
            end

            if statusline_length <= win_width then
                break
            end
        end

        -- If statusline still doesn't fit within window, iterate through components in order of
        -- priority once again and remove components with truncate_hide set to true until statusline
        -- fits within window
        if statusline_length > win_width then
            for _, indices in ipairs(component_indices) do
                local i, j = unpack(indices)

                if sections[i][j].truncate_hide then
                    statusline_length = statusline_length - component_lengths[i][j]
                    component_strs[i][j] = ''
                    component_lengths[i][j] = 0
                end

                if statusline_length <= win_width then
                    break
                end
            end
        end
    end

    -- Concatenate all components strings of each section to get a string for each section
    local section_strs = {}

    for i, section_component_strs in ipairs(component_strs) do
        section_strs[i] = table.concat(section_component_strs)
    end

    -- Then concatenate all the sections to get the statusline string, and return it
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
