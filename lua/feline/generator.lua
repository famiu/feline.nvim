local bo = vim.bo
local cmd = vim.cmd
local api = vim.api

local feline = require('feline')
local colors = feline.colors
local separators = feline.separators
local providers = require('feline.providers')

local M ={}
M.highlights = {}

-- Check if current buffer is forced to have inactive statusline
local function is_forced_inactive()
    local force_inactive = feline.force_inactive

    local buftype = bo.buftype
    local filetype = bo.filetype
    local bufname = api.nvim_buf_get_name(0)

    return vim.tbl_contains(force_inactive.buftypes, buftype) or
        vim.tbl_contains(force_inactive.filetypes, filetype) or
        vim.tbl_contains(force_inactive.bufnames, bufname)
end

-- Check if buffer contained in current window is configured to have statusline disabled
local function is_disabled(winid)
    local disable = {buftypes = {}, filetypes = {}, bufnames = {}}

    local buftype = bo.buftype
    local filetype = bo.filetype
    local bufname = api.nvim_buf_get_name(api.nvim_win_get_buf(winid))

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

-- Add highlight of component
local function add_component_highlight(name, fg, bg, style)
    cmd(string.format('highlight %s gui=%s guifg=%s guibg=%s', name, style, fg, bg))
    M.highlights[name] = true
    return name
end

local defhl = add_component_highlight('Default', colors.fg, colors.bg, 'NONE')

-- Parse highlight, inherit default/parent values if values are not given
-- Also generate unique name for highlight if name is not given
-- If given a string, accept it as an existing external highlight group
local function parse_hl(hl, parent_hl)
    if type(hl) == "string" then return hl end

    if hl == {} then return defhl end

    if hl.name then
        if M.highlights[hl.name] then
            return hl.name
        elseif pcall(api.nvim_get_hl_id_by_name(hl.name)) then
            M.highlights[hl.name] = true
            return hl.name
        end
    end

    parent_hl = parent_hl or {}

    hl.fg = hl.fg or parent_hl.fg or colors.fg
    hl.bg = hl.bg or parent_hl.bg or colors.bg
    hl.style = hl.style or 'NONE'

    if colors[hl.fg] then hl.fg = colors[hl.fg] end
    if colors[hl.bg] then hl.bg = colors[hl.bg] end

    -- Generate unique hl name from color strings if a name isn't provided
    hl.name = hl.name or string.format(
        'StatusComponent_%s_%s_%s',
        string.sub(hl.fg, 2),
        string.sub(hl.bg, 2),
        string.gsub(hl.style, ',', '_')
    )

    return add_component_highlight(hl.name, hl.fg, hl.bg, hl.style)
end

-- Parse component seperator
-- By default, foreground color of separator is background color of parent
-- and background color is set to default background color
local function parse_sep(sep, parent_bg)
    if sep == nil then return '' end

    local hl
    local str

    if type(sep) == "string" then
        str = sep
        hl = {fg = parent_bg, bg = colors.bg}
    else
        sep = evaluate_if_function(sep)
        str = sep.str or ''
        hl = evaluate_if_function(sep.hl) or {fg = parent_bg, bg = colors.bg}
    end

    if separators[str] then str = separators[str] end

    return '%#' .. parse_hl(hl) .. '#' .. str
end

-- Either parse a single separator or a list of separators with different highlights
local function parse_sep_list(sep_list, parent_bg)
    if sep_list == nil then return '' end

    if (type(sep_list) == "table" and sep_list[1] and
    (type(sep_list[1]) == "function" or type(sep_list[1]) == "table" or type(sep_list[1]) == "string")) then
        local sep_strs = {}

        for _,v in ipairs(sep_list) do
            sep_strs[#sep_strs+1] = parse_sep(v, parent_bg)
        end

        return table.concat(sep_strs)
    else
        return parse_sep(sep_list, parent_bg)
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

    return '%#' .. parse_hl(hl, parent_hl) .. '#' ..  str
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
        print(string.format(
            "Invalid provider! Provider must evaluate to string. Got type '%s' instead."
        ), type(provider))
    end

    return provider, icon
end

-- Parses a component alongside its highlight
local function parse_component(component, winid)
    local enabled = evaluate_if_function(component.enabled, true)

    if not enabled then return '' end

    local hl = evaluate_if_function(component.hl, {})

    local left_sep_str = parse_sep_list(component.left_sep, hl.bg)
    local right_sep_str = parse_sep_list(component.right_sep, hl.bg)

    local str, icon = parse_provider(component.provider, component, winid)

    local hlname = parse_hl(hl)

    if icon == nil and str ~= '' then
        icon = component.icon
    end

    icon = parse_icon(evaluate_if_function(icon), hl)

    return left_sep_str .. icon .. '%#' .. hlname .. '#' .. str .. right_sep_str
end

-- Parse components of a section of the statusline
-- (For old component table format)
local function parse_statusline_section_old(section, type, winid)
    if feline.components[section] and feline.components[section][type] then
        local section_components = {}

        for _, v in ipairs(feline.components[section][type]) do
            section_components[#section_components+1] = parse_component(v, winid)
        end

        return table.concat(section_components)
    else
        return ""
    end
end

-- Parse components of a section of the statusline
local function parse_statusline_section(section, winid)
    local components = {}

    for _, component in ipairs(section) do
        components[#components+1] = parse_component(component, winid)
    end

    return table.concat(components)
end

-- Generate statusline by parsing all components and return a string
function M.generate_statusline(winid)
    if not feline.components or is_disabled(winid) then
        return ''
    end

    local statusline_type

    if winid == api.nvim_get_current_win() and not is_forced_inactive() then
        statusline_type='active'
    else
        statusline_type='inactive'
    end

    -- Determine if the component table uses the old format or new format
    -- and parse it accordingly
    if(feline.components.active and feline.components.inactive) then
        local sections = {}

        for _, section in ipairs(feline.components[statusline_type]) do
            sections[#sections+1] = parse_statusline_section(section, winid)
        end

        return table.concat(sections, '%=')
    else
        return string.format(
            "%s%%=%s%%=%s",
            parse_statusline_section_old('left', statusline_type, winid),
            parse_statusline_section_old('mid', statusline_type, winid),
            parse_statusline_section_old('right', statusline_type, winid)
        )
    end
end

return M
