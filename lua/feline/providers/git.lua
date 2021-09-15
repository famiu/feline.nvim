local api = vim.api

local M = {}

function M.git_branch(component, winid)
    local icon
    local str = ''
    local ok, head = pcall(api.nvim_buf_get_var, api.nvim_win_get_buf(winid), 'gitsigns_head')

    if not ok then head = vim.g.gitsigns_head or '' end

    if head ~= '' then
        icon = component.icon or ' '
        str = str .. head
    end

    return str, icon
end

function M.git_diff_added(component, winid)
    local ok, gsd = pcall(api.nvim_buf_get_var, api.nvim_win_get_buf(winid), 'gitsigns_status_dict')

    local icon
    local str = ''

    if ok and gsd['added'] and gsd['added'] > 0 then
        icon = component.icon or '  '
        str = str .. gsd.added
    end

    return str, icon
end

function M.git_diff_removed(component, winid)
    local ok, gsd = pcall(api.nvim_buf_get_var, api.nvim_win_get_buf(winid), 'gitsigns_status_dict')

    local icon
    local str = ''

    if ok and gsd['removed'] and gsd['removed'] > 0 then
        icon = component.icon or '  '
        str = str .. gsd.removed
    end

    return str, icon
end

function M.git_diff_changed(component, winid)
    local ok, gsd = pcall(api.nvim_buf_get_var, api.nvim_win_get_buf(winid), 'gitsigns_status_dict')

    local icon
    local str = ''

    if ok and gsd['changed'] and gsd['changed'] > 0 then
        icon = component.icon or ' 柳'
        str = str .. gsd.changed
    end

    return str, icon
end

function M.git_info_exists(winid)
    local ok, _ = pcall(api.nvim_buf_get_var, api.nvim_win_get_buf(winid), 'gitsigns_status_dict')
    return ok
end

return M
