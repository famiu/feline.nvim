local M = {}

local lsp = vim.lsp
local diagnostic = vim.diagnostic

function M.is_lsp_attached()
    return next(lsp.buf_get_clients(0)) ~= nil
end

function M.get_diagnostics_count(severity)
    return vim.tbl_count(diagnostic.get(0, severity and { severity = severity }))
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

local function get_sign(signname)
    local sign = vim.fn.sign_getdefined(signname)

    if next(sign) ~= nil then
        return ' ' .. sign[1].text .. ' '
    end

    return ''
end

function M.diagnostic_errors()
    return diagnostics(diagnostic.severity.ERROR), get_sign('DiagnosticSignError')
end

function M.diagnostic_warnings()
    return diagnostics(diagnostic.severity.WARN), get_sign('DiagnosticSignWarn')
end

function M.diagnostic_info()
    return diagnostics(diagnostic.severity.INFO), get_sign('DiagnosticSignInfo')
end

function M.diagnostic_hints()
    return diagnostics(diagnostic.severity.HINT), get_sign('DiagnosticSignHint')
end

return M
