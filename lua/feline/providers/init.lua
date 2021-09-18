local vi_mode = require('feline.providers.vi_mode')
local cursor = require('feline.providers.cursor')
local file = require('feline.providers.file')
local lsp = require('feline.providers.lsp')
local git = require('feline.providers.git')

local M = {
    vi_mode = vi_mode.vi_mode,

    position = cursor.position,
    line_percentage = cursor.line_percentage,
    scroll_bar = cursor.scroll_bar,

    file_info = file.file_info,
    file_size = file.file_size,
    file_type = file.file_type,
    file_encoding = file.file_encoding,

    git_branch = git.git_branch,
    git_diff_added = git.git_diff_added,
    git_diff_removed = git.git_diff_removed,
    git_diff_changed = git.git_diff_changed,

    lsp_client_names = lsp.lsp_client_names,
    diagnostic_errors = lsp.diagnostic_errors,
    diagnostic_warnings = lsp.diagnostic_warnings,
    diagnostic_hints = lsp.diagnostic_hints,
    diagnostic_info = lsp.diagnostic_info,
}

function M.add_provider(name, provider)
    if M[name] then
        vim.api.nvim_err_writeln(string.format(
            "Provider %s already exists! Please try using another name",
            name
        ))
    else
        M[name] = provider
    end
end

return M
