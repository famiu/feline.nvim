local M = {}

local vi_mode = require('feline.providers.vi_mode')
local cursor = require('feline.providers.cursor')
local file = require('feline.providers.file')
local lsp = require('feline.providers.lsp')
local git = require('feline.providers.git')

M.vi_mode = vi_mode.vi_mode

M.position = cursor.position
M.line_percentage = cursor.line_percentage
M.scroll_bar = cursor.scroll_bar

M.file_info = file.file_info
M.file_size = file.file_size
M.file_type = file.file_type
M.file_encoding = file.file_encoding

M.git_branch = git.git_branch
M.git_diff_added = git.git_diff_added
M.git_diff_removed = git.git_diff_removed
M.git_diff_changed = git.git_diff_changed

M.diagnostic_errors = lsp.diagnostic_errors
M.diagnostic_warnings = lsp.diagnostic_warnings
M.diagnostic_hints = lsp.diagnostic_hints
M.diagnostic_info = lsp.diagnostic_info

function M.add_provider(name, provider)
    if M[name] then
        print("Provider " .. name .. " already exists! Please try using another name")
    else
        M[name] = provider
    end
end

return M
