local b = vim.b

local M = {}

function M.git_branch()
    return b.gitsigns_head or '', ' '
end

-- Common function used by the git providers
local function git_diff(type)
    local gsd = b.gitsigns_status_dict

    if gsd and gsd[type] and gsd[type] > 0 then
        return tostring(gsd[type])
    end

    return ''
end

function M.git_diff_added()
    return git_diff('added'), '  '
end

function M.git_diff_removed()
    return git_diff('removed'), '  '
end

function M.git_diff_changed()
    return git_diff('changed'), ' 柳'
end

-- Utility function to check if git provider information is available
function M.git_info_exists()
    return b.gitsigns_head or b.gitsigns_status_dict
end

return M
