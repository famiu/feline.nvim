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

function M.lsp_client_names(component, winnr)
    local clients = {}
    local icon = component.icon or ' '

    for _, client in pairs(vim.lsp.buf_get_clients(api.nvim_win_get_buf(winnr))) do
        clients[#clients+1] = client.name
    end

    return table.concat(clients, ' '), icon
end

function M.diagnostic_errors(component, winnr)
    local count = M.get_diagnostics_count('Error', api.nvim_win_get_buf(winnr))
    if not count or count == 0 then return '' end
    return tostring(count), (component.icon or '  ')
end

function M.diagnostic_warnings(component, winnr)
    local count = M.get_diagnostics_count('Warning', api.nvim_win_get_buf(winnr))
    if not count or count == 0 then return '' end
    return tostring(count), (component.icon or '  ')
end

function M.diagnostic_hints(component, winnr)
    local count = M.get_diagnostics_count('Hint', api.nvim_win_get_buf(winnr))
    if not count or count == 0 then return '' end
    return tostring(count), (component.icon or '  ')
end

function M.diagnostic_info(component, winnr)
    local count = M.get_diagnostics_count('Information', api.nvim_win_get_buf(winnr))
    if not count or count == 0 then return '' end
    return tostring(count), (component.icon or '  ')
end

return M
