local api = vim.api

local M = {}

function M.git_branch(component, winnr)
    local icon
    local str = ''
    local ok, head = pcall(
        api.nvim_buf_get_var,
        api.nvim_win_get_buf(winnr),
        'gitsigns_head'
    )

    if not ok then head = vim.g.gitsigns_head or '' end

    if head ~= '' then
        icon = component.icon or ' '
        str = str .. head
    end

    return str, icon
end

function M.git_diff_added(component, winnr)
    local ok, gsd = pcall(
        api.nvim_buf_get_var,
        api.nvim_win_get_buf(winnr),
        'gitsigns_status_dict'
    )

    local icon
    local str = ''

    if ok and gsd['added'] and gsd['added'] > 0 then
        icon = component.icon or '  '
        str = str .. gsd.added
    end

    return str, icon
end

function M.git_diff_removed(component, winnr)
    local ok, gsd = pcall(
        api.nvim_buf_get_var,
        api.nvim_win_get_buf(winnr),
        'gitsigns_status_dict'
    )

    local icon
    local str = ''

    if ok and gsd['removed'] and gsd['removed'] > 0 then
        icon = component.icon or '  '
        str = str .. gsd.removed
    end

    return str, icon
end

function M.git_diff_changed(component, winnr)
    local ok, gsd = pcall(
        api.nvim_buf_get_var,
        api.nvim_win_get_buf(winnr),
        'gitsigns_status_dict'
    )

    local icon
    local str = ''

    if ok and gsd['changed'] and gsd['changed'] > 0 then
        icon = component.icon or ' 柳'
        str = str .. gsd.changed
    end

    return str, icon
end

return M
