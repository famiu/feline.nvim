local M = {}

local lsp = vim.lsp

local severities = {
  INFO="Information",
  HINT="Hint",
  WARN="Warning",
  ERROR="Error",
}

function M.is_lsp_attached()
    return next(lsp.buf_get_clients(0)) ~= nil
end

function M.get_diagnostics_count(severity)
    local active_clients = lsp.buf_get_clients(0)

    if not active_clients then return 0 end

    local count = 0

    if vim.fn.has('nvim-0.6') then
      count = vim.tbl_count(vim.diagnostic.get(0, { severity = vim.diagnostic.severity[severity]}))
    else
      severity = severities[severity]
      for _, client in pairs(active_clients) do
        count = count + lsp.diagnostic.get_count(0,severity, client.id)
      end
    end

    return count
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
    return diagnostics('ERROR'), '  '
end

function M.diagnostic_warnings()
    return diagnostics('WARN'), '  '
end

function M.diagnostic_hints()
    return diagnostics('HINT'), '  '
end

function M.diagnostic_info()
    return diagnostics('INFO'), '  '
end

return M
