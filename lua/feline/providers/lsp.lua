local M = {}

function M.is_lsp_attached()
    return next(vim.lsp.buf_get_clients()) ~= nil
end

function M.get_diagnostics_count(severity)
    local bufnr = vim.api.nvim_get_current_buf()
    local active_clients = vim.lsp.buf_get_clients(bufnr)

    if not active_clients then return nil end

    local count = 0
    for _, client in pairs(active_clients) do
        count = count + vim.lsp.diagnostic.get_count(bufnr, severity, client.id)
    end

    return count
end

function M.diagnostics_exist(severity)
    local diagnostics_count = M.get_diagnostics_count(severity)
    return diagnostics_count and diagnostics_count > 0
end

function M.lsp_client_names(component)
    local clients = {}
    local icon = component.icon or ' '

    for _, client in pairs(vim.lsp.buf_get_clients()) do
        clients[#clients+1] = client.name
    end

    return table.concat(clients, ' '), icon
end

function M.diagnostic_errors(component)
    local count = M.get_diagnostics_count('Error')
    if not count or count == 0 then return '' end
    return tostring(count), (component.icon or '  ')
end

function M.diagnostic_warnings(component)
    local count = M.get_diagnostics_count('Warning')
    if not count or count == 0 then return '' end
    return tostring(count), (component.icon or '  ')
end

function M.diagnostic_hints(component)
    local count = M.get_diagnostics_count('Hint')
    if not count or count == 0 then return '' end
    return tostring(count), (component.icon or '  ')
end

function M.diagnostic_info(component)
    local count = M.get_diagnostics_count('Information')
    if not count or count == 0 then return '' end
    return tostring(count), (component.icon or '  ')
end

return M
