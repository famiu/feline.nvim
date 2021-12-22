local lazy_require = require('feline.utils').lazy_require

-- All available provider categories (lazy loaded)
local provider_categories = {
    vi_mode = lazy_require('feline.providers.vi_mode'),
    cursor = lazy_require('feline.providers.cursor'),
    file = lazy_require('feline.providers.file'),
    lsp = lazy_require('feline.providers.lsp'),
    git = lazy_require('feline.providers.git'),
    custom = {},
}

-- Categories that each provider belongs to
local get_provider_category = {
    vi_mode = 'vi_mode',

    position = 'cursor',
    line_percentage = 'cursor',
    scroll_bar = 'cursor',

    file_info = 'file',
    file_size = 'file',
    file_type = 'file',
    file_encoding = 'file',
    file_format = 'file',

    git_branch = 'git',
    git_diff_added = 'git',
    git_diff_removed = 'git',
    git_diff_changed = 'git',

    lsp_client_names = 'lsp',
    diagnostic_errors = 'lsp',
    diagnostic_warnings = 'lsp',
    diagnostic_hints = 'lsp',
    diagnostic_info = 'lsp',
}

-- Providers that have been loaded
local loaded_providers = {}

-- Return a metatable that automatically loads and returns providers when their name is indexed
return setmetatable({}, {
    __index = function(_, key)
        -- If a provider hasn't been loaded, load it by accessing its category and indexing the name
        -- which causes lazy_require to actually load the provider category
        if not loaded_providers[key] then
            local category = get_provider_category[key]

            if category then
                loaded_providers[key] = provider_categories[category][key]
            end
        end

        return loaded_providers[key]
    end,
    -- Add new custom providers by appending their value to the custom provider category and setting
    -- the category of their name to 'custom'
    __newindex = function(_, name, provider)
        if get_provider_category[name] then
            vim.api.nvim_err_writeln(
                string.format(
                    'Feline: error while adding provider: '
                        .. "Provider '%s' already exists! Please try using another name",
                    name
                )
            )
        else
            provider_categories.custom[name] = provider
            get_provider_category[name] = 'custom'
        end
    end,
})
