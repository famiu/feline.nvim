local bo = vim.bo
local api = vim.api

local feline = require('feline')
local providers = require('feline.providers')
local components = feline.components
local colors = feline.colors
local separators = feline.separators
local disable = feline.disable
local force_inactive = feline.force_inactive

local M = {
    highlights = {}
}

-- Check if current buffer is forced to have inactive statusline
local function is_forced_inactive()
    local buftype = bo.buftype
    local filetype = bo.filetype
    local bufname = api.nvim_buf_get_name(0)

    return vim.tbl_contains(force_inactive.buftypes, buftype) or
        vim.tbl_contains(force_inactive.filetypes, filetype) or
        vim.tbl_contains(force_inactive.bufnames, bufname)
end

-- Check if buffer contained in window is configured to have statusline disabled
local function is_disabled(winid)
    local bufnr = api.nvim_win_get_buf(winid)

    local buftype = bo[bufnr].buftype
    local filetype = bo[bufnr].filetype
    local bufname = api.nvim_buf_get_name(bufnr)

    return vim.tbl_contains(disable.buftypes, buftype) or
        vim.tbl_contains(disable.filetypes, filetype) or
        vim.tbl_contains(disable.bufnames, bufname)
end

-- Evaluate a component key if it is a function, else return the value
-- Also returns specified default value if value is nil
local function evaluate_if_function(key, default)
    if key == nil then
        return default
    elseif type(key) == "function" then
        return key()
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

-- Parse highlight, inherit default/parent values if values are not given
-- Also generate unique name for highlight if name is not given
-- If given a string, accept it as an existing external highlight group
local function parse_hl(hl, parent_hl)
    if type(hl) == "string" then return hl end

    if hl.name and M.highlights[hl.name] then
        return hl.name
    end

    parent_hl = parent_hl or {}

    hl.fg = hl.fg or parent_hl.fg or colors.fg
    hl.bg = hl.bg or parent_hl.bg or colors.bg
    hl.style = hl.style or parent_hl.style or 'NONE'

    if colors[hl.fg] then hl.fg = colors[hl.fg] end
    if colors[hl.bg] then hl.bg = colors[hl.bg] end

    -- Generate unique hl name from color strings if a name isn't provided
    hl.name = hl.name or string.format(
        'StatusComponent_%s_%s_%s',
        string.sub(hl.fg, 2),
        string.sub(hl.bg, 2),
        string.gsub(hl.style, ',', '_')
    )

    if not M.highlights[hl.name] then
        add_hl(hl.name, hl.fg, hl.bg, hl.style)
    end

    return hl.name
end

-- Parse component seperator
-- By default, foreground color of separator is background color of parent
-- and background color is set to default background color
local function parse_sep(sep, parent_bg, is_component_empty)
    if sep == nil then return '' end

    local hl
    local str

    if type(sep) == "string" then
        if is_component_empty then return '' end

        str = sep
        hl = {fg = parent_bg, bg = colors.bg}
    else
        sep = evaluate_if_function(sep)

        if is_component_empty and not sep.always_visible then return '' end

        str = sep.str or ''
        hl = evaluate_if_function(sep.hl) or {fg = parent_bg, bg = colors.bg}
    end

    if separators[str] then str = separators[str] end

    return string.format('%%#%s#%s', parse_hl(hl), str)
end

-- Either parse a single separator or a list of separators with different highlights
local function parse_sep_list(sep_list, parent_bg, is_component_empty)
    if sep_list == nil then return '' end

    parent_bg = parent_bg or colors.fg

    if (type(sep_list) == "table" and sep_list[1] and
    (type(sep_list[1]) == "function" or type(sep_list[1]) == "table" or type(sep_list[1]) == "string")) then
        local sep_strs = {}

        for _,v in ipairs(sep_list) do
            sep_strs[#sep_strs+1] = parse_sep(v, parent_bg, is_component_empty)
        end

        return table.concat(sep_strs)
    else
        return parse_sep(sep_list, parent_bg, is_component_empty)
    end
end

-- Parse component icon
-- By default, icon inherits component highlights
local function parse_icon(icon, parent_hl)
    if icon == nil then return '' end

    local str
    local hl

    if type(icon) == "string" then
        str = icon
        hl = parent_hl
    else
        icon = evaluate_if_function(icon)
        str = icon.str or ''
        hl = evaluate_if_function(icon.hl) or parent_hl
    end

    return string.format('%%#%s#%s', parse_hl(hl, parent_hl), str)
end

-- Parse component provider
local function parse_provider(provider, component, winid)
    local icon

    if type(provider) == "string" and type(providers[provider]) == "function" then
        provider, icon = providers[provider](component, winid)
    elseif type(provider) == "function" then
        provider, icon = provider(component, winid)
    end

    if type(provider) ~= "string" then
        api.nvim_err_writeln(string.format(
            "Invalid provider! Provider must evaluate to string. Got type '%s' instead",
            type(provider)
        ))
    end

    return provider, icon
end

-- Parses a component alongside its highlight
local function parse_component(component, winid)
    local enabled

    if component.enabled then enabled = component.enabled else enabled = true end

    if type(enabled) == 'function' then
        enabled = enabled(winid)
    end

    if not enabled then return '' end

    local str, icon = parse_provider(component.provider, component, winid)

    local hl = evaluate_if_function(component.hl, {})

    local is_component_empty = str == ''

    local left_sep_str = parse_sep_list(component.left_sep, hl.bg, is_component_empty)
    local right_sep_str = parse_sep_list(component.right_sep, hl.bg, is_component_empty)

    local hlname = parse_hl(hl)

    if is_component_empty then
        icon = nil
    elseif component.icon then
        icon = component.icon
    end

    icon = parse_icon(evaluate_if_function(icon), hl)

    return string.format('%s%s%%#%s#%s%s', left_sep_str, icon, hlname, str, right_sep_str)
end

-- Parse components of a section of the statusline
-- (For old component table format)
local function parse_statusline_section_old(section, type, winid)
    if components[section] and components[section][type] then
        local section_components = {}

        for _, v in ipairs(components[section][type]) do
            section_components[#section_components+1] = parse_component(v, winid)
        end

        return table.concat(section_components)
    else
        return ''
    end
end

-- Parse components of a section of the statusline
local function parse_statusline_section(section, winid)
    local section_components = {}

    for _, component in ipairs(section) do
        section_components[#section_components+1] = parse_component(component, winid)
    end

    return table.concat(section_components)
end

-- Generate statusline by parsing all components and return a string
function M.generate_statusline(winid)
    local statusline_str

    if not components or is_disabled(winid) then
        statusline_str = ''
    else
        local statusline_type

        if winid == api.nvim_get_current_win() and not is_forced_inactive() then
            statusline_type='active'
        else
            statusline_type='inactive'
        end

        -- Determine if the component table uses the old format or new format
        -- and parse it accordingly
        if components.active or components.inactive then
            local statusline = components[statusline_type]

            if not statusline or statusline == {} then
                statusline_str = ''
            else
                local sections = {}

                for _, section in ipairs(statusline) do
                    sections[#sections+1] = parse_statusline_section(section, winid)
                end

                statusline_str = table.concat(sections, '%=')
            end
        else
            statusline_str = string.format(
                '%s%%=%s%%=%s',
                parse_statusline_section_old('left', statusline_type, winid),
                parse_statusline_section_old('mid', statusline_type, winid),
                parse_statusline_section_old('right', statusline_type, winid)
            )
        end
    end

    -- Never return an empty string since setting statusline to an empty string or nil
    -- makes it use the global statusline value
    if statusline_str == '' then
        return string.format('%%#%s#', defhl())
    else
        return statusline_str
    end
end

return M
