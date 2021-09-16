local M = {}

local api = vim.api

function M.is_lsp_attached(bufnr)
    bufnr = bufnr or api.nvim_get_current_buf()

    return next(vim.lsp.buf_get_clients(bufnr)) ~= nil
end

function M.get_diagnostics_count(severity, bufnr)
    bufnr = bufnr or api.nvim_get_current_buf()

    local active_clients = vim.lsp.buf_get_clients(bufnr)

    if not active_clients then return nil end

    local count = 0

    for _, client in pairs(active_clients) do
        count = count + vim.lsp.diagnostic.get_count(bufnr, severity, client.id)
    end

    return count
end

function M.diagnostics_exist(severity, bufnr)
    bufnr = bufnr or api.nvim_get_current_buf()

    local diagnostics_count = M.get_diagnostics_count(severity, bufnr)
    return diagnostics_count and diagnostics_count > 0
end

function M.lsp_client_names(_, winid)
    local clients = {}

    for _, client in pairs(vim.lsp.buf_get_clients(api.nvim_win_get_buf(winid))) do
        clients[#clients+1] = client.name
    end

    return table.concat(clients, ' '),  ' '
end

-- Common function used by the diagnostics providers
local function diagnostics(winid, severity)
    local count = M.get_diagnostics_count(severity, api.nvim_win_get_buf(winid))

    if not count or count == 0 then return '' end
    return tostring(count)
end

function M.diagnostic_errors(_, winid)
    return diagnostics(winid, 'Error'), '  '
end

function M.diagnostic_warnings(_, winid)
    return diagnostics(winid, 'Warning'), '  '
end

function M.diagnostic_hints(_, winid)
    return diagnostics(winid, 'Hint'), '  '
end

function M.diagnostic_info(_, winid)
    return diagnostics(winid, 'Information'), '  '
end

return M
