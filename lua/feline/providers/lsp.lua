local M = {}

local lsp = vim.lsp
local diagnostic = vim.diagnostic

-- Initialize a local table with severity names to prevent having to create a table in every call of
-- the diagnostic function to improve performance
local severity_names = { "Information", "Hint", "Warning", "Error" }

function M.is_lsp_attached()
    return next(lsp.buf_get_clients(0)) ~= nil
end

function M.get_diagnostics_count(severity)
    if vim.fn.has("nvim-0.6") == 1 then
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
        clients[#clients+1] = client.name
    end

    return table.concat(clients, ' '),  ' '
end

-- Common function used by the diagnostics providers
local function diagnostics(severity)
    local count = M.get_diagnostics_count(severity)

    return count ~= 0 and tostring(count) or ''
end

function M.diagnostic_errors()
    return diagnostics(diagnostic.severity.ERROR), '  '
end

function M.diagnostic_warnings()
    return diagnostics(diagnostic.severity.WARN), '  '
end

function M.diagnostic_info()
    return diagnostics(diagnostic.severity.INFO), '  '
end

function M.diagnostic_hints()
    return diagnostics(diagnostic.severity.HINT), '  '
end

return M
