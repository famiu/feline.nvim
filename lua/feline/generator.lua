local bo = vim.bo
local api = vim.api

local feline = require('feline')
local providers = feline.providers
local components = feline.components
local colors = feline.colors
local separators = feline.separators
local disable = feline.disable
local force_inactive = feline.force_inactive

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

-- Return default highlight
local function defhl()
    if not M.highlights['StatusComponentDefault'] then
        add_hl('StatusComponentDefault', colors.fg, colors.bg, 'NONE')
    end

    return 'StatusComponentDefault'
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

-- Parse component seperator
-- By default, foreground color of separator is background color of parent
-- and background color is set to default background color
local function parse_sep(sep, parent_bg, is_component_empty)
    if sep == nil then return '' end

    local hl
    local str

    if type(sep) == 'string' then
        if is_component_empty then return '' end

        str = sep
        hl = {fg = parent_bg, bg = colors.bg}
    else
        if is_component_empty and not sep.always_visible then return '' end

        str = sep.str or ''
        hl = sep.hl or {fg = parent_bg, bg = colors.bg}
    end

    if separators[str] then str = separators[str] end

    return string.format('%%#%s#%s', get_hlname(hl), str)
end

-- Either parse a single separator or a list of separators with different highlights
local function parse_sep_list(sep_list, parent_bg, is_component_empty, winid)
    if sep_list == nil then return '' end

    if (type(sep_list) == 'table' and sep_list[1] and (type(sep_list[1]) == 'function' or
    type(sep_list[1]) == 'table' or type(sep_list[1]) == 'string')) then
        local sep_strs = {}

        for _,v in ipairs(sep_list) do
            sep_strs[#sep_strs+1] = parse_sep(
                evaluate_if_function(v, winid),
                parent_bg,
                is_component_empty
            )
        end

        return table.concat(sep_strs)
    else
        return parse_sep(evaluate_if_function(sep_list, winid), parent_bg, is_component_empty)
    end
end

-- Parse component icon
-- By default, icon inherits component highlights
local function parse_icon(icon, parent_hl, is_component_empty)
    if icon == nil then return '' end

    local hl
    local str

    if type(icon) == "string" then
        if is_component_empty then return '' end

        str = icon
        hl = parent_hl
    else
        if is_component_empty and not icon.always_visible then return '' end

        str = icon.str or ''
        hl = icon.hl or parent_hl
    end

    return string.format('%%#%s#%s', get_hlname(hl, parent_hl), str)
end

-- Parse component provider
local function parse_provider(provider, winid, component)
    local icon

    -- If provider is a string and its name matches the name of a registered provider, use it
    if type(provider) == "string" and providers[provider] then
        provider, icon = providers[provider](winid, component, {})
    -- If provider is a function, just evaluate it normally
    elseif type(provider) == "function" then
        provider, icon = provider(winid, component)
    -- If provider is a table, get the provider name and opts and evaluate the provider
    elseif type(provider) == "table" then
        provider, icon = providers[provider.name](winid, component, provider.opts or {})
    end

    return provider, icon
end

-- Parses a component alongside its highlight
local function parse_component(component, winid)
    local enabled

    if component.enabled then enabled = component.enabled else enabled = true end

    enabled = evaluate_if_function(enabled, winid)

    if not enabled then return '' end

    local str, icon = parse_provider(component.provider, winid, component)

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

    local is_component_empty = str == ''

    local left_sep_str = parse_sep_list(
        component.left_sep,
        hl.bg,
        is_component_empty,
        winid
    )

    local right_sep_str = parse_sep_list(
        component.right_sep,
        hl.bg,
        is_component_empty,
        winid
    )

    icon = parse_icon(evaluate_if_function(component.icon or icon, winid), hl, is_component_empty)

    if is_component_empty then
        return string.format(
            '%s%s%s',
            left_sep_str,
            icon,
            right_sep_str
        )
    else
        return string.format(
            '%s%s%%#%s#%s%s',
            left_sep_str,
            icon,
            hlname or get_hlname(hl),
            str,
            right_sep_str
        )
    end
end

-- Parse components of a section of the statusline
local function parse_statusline_section(section, winid, statusline_type, section_index)
    local section_components = {}

    for i, component in ipairs(section) do
        local ok, result = pcall(parse_component, component, winid)

        if ok then
            section_components[#section_components+1] = result
        else
            api.nvim_err_writeln(string.format(
                "Feline: error while processing component number %d on section %d of type '%s': %s",
                i, section_index, statusline_type, result
            ))
        end
    end

    return table.concat(section_components)
end

-- Generate statusline by parsing all components and return a string
function M.generate_statusline(winid)
    local statusline_str = ''

    if components and not is_disabled(winid) then
        local statusline_type

        if winid == api.nvim_get_current_win() and not is_forced_inactive() then
            statusline_type='active'
        else
            statusline_type='inactive'
        end

        local statusline = components[statusline_type]

        if statusline then
            local sections = {}

            for i, section in ipairs(statusline) do
                sections[#sections+1] = parse_statusline_section(section, winid, statusline_type, i)
            end

            statusline_str = table.concat(sections, string.format('%%#%s#%%=', defhl()))
        end
    end

    -- Never return an empty string since setting statusline to an empty string will make it
    -- use the global statusline value (same as active statusline) for inactive windows
    if statusline_str == '' then
        return string.format('%%#%s#', defhl())
    else
        return statusline_str
    end
end

return M
