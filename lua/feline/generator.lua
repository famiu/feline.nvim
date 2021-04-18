local bo = vim.bo
local fn = vim.fn

local utils = require('feline.utils')
local colors = require('feline.defaults').colors
local separators = require('feline.defaults').separators
local providers = require('feline.providers')

local defhl = utils.add_component_highlight('Default', colors.fg, colors.bg, 'NONE')

local M = {
    components = {},
    properties = {}
}

-- Check if current buffer is forced to have inactive statusline
local function is_forced_inactive()
    local force_inactive = M.properties.force_inactive

    local buftype = bo.buftype
    local filetype = bo.filetype
    local bufname = fn.bufname()

    return fn.index(force_inactive.buftypes, buftype) ~= -1 or
        fn.index(force_inactive.filetypes, filetype) ~= -1 or
        fn.index(force_inactive.bufnames, bufname) ~= -1
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

-- Parse highlight, generate default values if values are not given
-- Also generate unique name for highlight if name is not given
local function parse_hl(hl)
    if hl == {} then return defhl end

    hl.fg = hl.fg or colors.fg
    hl.bg = hl.bg or colors.bg
    hl.style = hl.style or 'NONE'

    if colors[hl.fg] then hl.fg = colors[hl.fg] end
    if colors[hl.bg] then hl.bg = colors[hl.bg] end

    -- Generate unique hl name from color strings if a name isn't provided
    hl.name = hl.name or string.format(
        '_%s_%s_%s',
        string.gsub(hl.fg, '^#', ''),
        string.gsub(hl.bg, '^#', ''),
        string.gsub(hl.style, ',', '_')
    )

    return utils.add_component_highlight(hl.name, hl.fg, hl.bg, hl.style)
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
        hl = sep.hl or {fg = parent_bg, bg = colors.bg}
    end

    if separators[str] then str = separators[str] end

    return '%#' .. parse_hl(hl) .. '#' .. str
end

-- Either parse a single separator or a list of separators with different highlights
local function parse_sep_list(sep_list, parent_bg)
    if sep_list == nil then return '' end

    if (type(sep_list) == "table" and sep_list[1] and
    (type(sep_list[1]) == "table" or type(sep_list[1]) == "string")) then
        local sep_strs = {}

        for _,v in ipairs(sep_list) do
            sep_strs[#sep_strs+1] = parse_sep(v, parent_bg)
        end

        return table.concat(sep_strs)
    else
        return parse_sep(sep_list, parent_bg)
    end
end

-- Parse component provider
local function parse_provider(provider, component)
    if type(provider) == "string" and type(providers[provider]) == "function" then
        provider = providers[provider](component)
    elseif type(provider) == "function" then
        provider = provider(component)
    end

    if type(provider) ~= "string" then
        print(string.format(
            "Invalid provider! Provider must evaluate to string. Got type '%s' instead."
        ), type(provider))
    end

    return provider
end

-- Parses a component alongside its highlight
local function parse_component(component)
    local enabled = evaluate_if_function(component.enabled, true)

    if not enabled then return '' end

    local hl = evaluate_if_function(component.hl, {})
    local icon = evaluate_if_function(component.icon)

    local left_sep_str = parse_sep_list(component.left_sep, hl.bg)
    local right_sep_str = parse_sep_list(component.right_sep, hl.bg)

    local provider = parse_provider(component.provider, component)

    local hlname = parse_hl(hl)

    return left_sep_str .. '%#' .. hlname .. '#' .. provider .. right_sep_str
end

-- Generate statusline by parsing all components and return a string
function M.generate_statusline(is_active)
    local statusline_components = {}
    local statusline_type

    if is_active and not is_forced_inactive() then
        statusline_type="active"
    else
        statusline_type="inactive"
    end

    for _,v in ipairs(M.components.left[statusline_type]) do
        statusline_components[#statusline_components+1] = parse_component(v)
    end

    statusline_components[#statusline_components+1] = '%='

    for _,v in ipairs(M.components.mid[statusline_type]) do
        statusline_components[#statusline_components+1] = parse_component(v)
    end

    statusline_components[#statusline_components+1] = '%='

    for _,v in ipairs(M.components.right[statusline_type]) do
        statusline_components[#statusline_components+1] = parse_component(v)
    end

    return table.concat(statusline_components)
end

return M
