local M = {}

function M.git_branch(component)
    local gsd = vim.b.gitsigns_status_dict

    local icon
    local str = ''

    if gsd and gsd.head and #gsd.head > 0 then
        icon = component.icon or ' '
        str = str .. gsd.head
    end

    return str, icon
end

function M.git_diff_added(component)
    local gsd = vim.b.gitsigns_status_dict

    local icon
    local str = ''

    if gsd and gsd['added'] and gsd['added'] > 0 then
        icon = component.icon or '  '
        str = str .. gsd.added
    end

    return str, icon
end

function M.git_diff_removed(component)
    local gsd = vim.b.gitsigns_status_dict

    local icon
    local str = ''

    if gsd and gsd['removed'] and gsd['removed'] > 0 then
        icon = component.icon or '  '
        str = str .. gsd.removed
    end

    return str, icon
end

function M.git_diff_changed(component)
    local gsd = vim.b.gitsigns_status_dict

    local icon
    local str = ''

    if gsd and gsd['changed'] and gsd['changed'] > 0 then
        icon = component.icon or ' 柳 '
        str = str .. gsd.changed
    end

    return str, icon
end

return M
