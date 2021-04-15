local lsp = vim.lsp
local M = {}

function M.is_lsp_attached()
    return next(vim.lsp.buf_get_clients()) ~= nil
end

function M.get_diagnostics_count(severity)
    if not M.is_lsp_attached() then return nil end

    local bufnr = vim.api.nvim_get_current_buf()
    local active_clients = lsp.get_active_clients()
    local count = 0

    for _, client in ipairs(active_clients) do
        count = count + lsp.diagnostic.get_count(bufnr, severity, client.id)
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
        table.insert(clients, icon .. client.name)
    end

    return table.concat(clients, ' ')
end

function M.diagnostic_errors(component)
    return (component.icon or '  ') .. M.get_diagnostics_count('Error')
end

function M.diagnostic_warnings(component)
    return (component.icon or '  ') .. M.get_diagnostics_count('Warning')
end

function M.diagnostic_hints(component)
    return (component.icon or '  ') .. M.get_diagnostics_count('Hint')
end

function M.diagnostic_info(component)
    return (component.icon or '  ') .. M.get_diagnostics_count('Information')
end

return M
