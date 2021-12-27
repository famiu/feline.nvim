local M = {}

local lsp = vim.lsp
local diagnostic = vim.diagnostic

local severity_names = { 'Error', 'Warning', 'Information', 'Hint' }

function M.is_lsp_attached()
    return next(lsp.buf_get_clients(0)) ~= nil
end

function M.get_diagnostics_count(severity)
    if vim.fn.has('nvim-0.6') == 1 then
        return vim.tbl_count(diagnostic.get(0, severity and { severity = severity }))
    else
        -- TODO: drop this when 0.5 is no longer used
        return lsp.diagnostic.get_count(0, severity and severity_names[severity])
    end
end

function M.diagnostics_exist(severity)
    return M.get_diagnostics_count(severity) > 0
end

function M.lsp_client_names()
    local clients = {}

    for _, client in pairs(lsp.buf_get_clients(0)) do
        clients[#clients + 1] = client.name
    end

    return table.concat(clients, ' '), ' '
end

-- Common function used by the diagnostics providers
local function diagnostics(severity)
    local count = M.get_diagnostics_count(severity)

    return count ~= 0 and tostring(count) or ''
end

function M.diagnostic_errors()
    -- TODO: replace with diagnostic.severity.ERROR when 0.5 is no longer used
    return diagnostics(1), '  '
end

function M.diagnostic_warnings()
    -- TODO: replace with diagnostic.severity.WARN when 0.5 is no longer used
    return diagnostics(2), '  '
end

function M.diagnostic_info()
    -- TODO: replace with diagnostic.severity.INFO when 0.5 is no longer used
    return diagnostics(3), '  '
end

function M.diagnostic_hints()
    -- TODO: replace with diagnostic.severity.HINT when 0.5 is no longer used
    return diagnostics(4), '  '
end

return M
