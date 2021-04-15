local b = vim.b
local M = {}

function M.git_branch(component)
    if not b.gitsigns_status_dict then return '' end

    local head = b.gitsigns_status_dict.head

    if #head > 0 then
        local icon = component.icon or '  '
        return icon .. head
    else
        return ''
    end
end

function M.git_diff_added(component)
    if b.gitsigns_status_dict and b.gitsigns_status_dict['added']
    and b.gitsigns_status_dict['added'] > 0 then
        local icon = component.icon or '  '
        return icon .. b.gitsigns_status_dict.added
    else
        return ''
    end
end

function M.git_diff_removed(component)
    if b.gitsigns_status_dict and b.gitsigns_status_dict['removed']
    and b.gitsigns_status_dict['removed'] > 0 then
        local icon = component.icon or '  '
        return icon .. b.gitsigns_status_dict.removed
    else
        return ''
    end
end

function M.git_diff_changed(component)
    if b.gitsigns_status_dict and b.gitsigns_status_dict['changed']
    and b.gitsigns_status_dict['changed'] > 0 then
        local icon = component.icon or ' 柳'
        return icon .. b.gitsigns_status_dict.changed
    else
        return ''
    end
end

return M
