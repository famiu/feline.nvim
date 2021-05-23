local fn = vim.fn
local o = vim.o
local bo = vim.bo

local M = {}

-- Filters out values of a table
local function filter(tbl, func, preserve_key)
    preserve_key = preserve_key or false

    local ret = {}

    if preserve_key then
        for k, v in pairs(tbl) do
            if func(v) then
                ret[k] = v
            end
        end
    else
        for _, v in pairs(tbl) do
            if func(v) then
                ret[#ret+1] = v
            end
        end
    end

    return ret
end

local function map(tbl, func)
    local ret = {}

    for k, v in pairs(tbl) do
        ret[k] = func(v)
    end

    return ret
end

-- Get the names of all current listed buffers
local function get_current_filenames()
    local listed_buffers = filter(fn.getbufinfo(), function(buffer)
        return buffer.listed == 1
    end)

    return map(listed_buffers, function(buffer) return buffer.name end)
end

-- Get unique name for the current buffer
local function get_unique_filename(filename)
    local filenames = filter(get_current_filenames(),
        function(filename_other)
            return filename_other ~= filename
        end
    )

    filename = string.reverse(filename)

    local index

    if next(filenames) then
        filenames = map(filenames, string.reverse)

        index = math.max(unpack(map(filenames,
            function(filename_other)
                for i = 1, #filename do
                    if filename:sub(i, i) ~= filename_other:sub(i, i) then
                        return i
                    end
                end
            end
        )))
    else
        index = 0
    end

    while index <= #filename do
        if filename:sub(index, index) == "/" then
            index = index - 1
            break
        end

        index = index + 1
    end

    return string.reverse(string.sub(filename, 0, index))

end

function M.file_info(component)
    local filename

    component.type = component.type or 'base-only'

    if component.type == 'full-path' then
        filename = fn.expand('%:p')
    elseif component.type == 'short-path' then
        filename = fn.pathshorten(fn.expand('%:p'))
    elseif component.type == 'base-only' then
        filename = fn.expand('%:t')
    elseif component.type == 'relative' then
        filename = fn.fnamemodify(fn.expand("%"), ":~:.")
    elseif component.type == 'relative-short' then
        filename = fn.pathshorten(fn.fnamemodify(fn.expand("%"), ":~:."))
    elseif component.type == 'unique' then
        filename = get_unique_filename(fn.expand('%:p'))
    elseif component.type == 'unique-short' then
        filename = get_unique_filename(fn.pathshorten(fn.expand('%:p')))
    else
        filename = fn.expand('%:t')
    end


    local extension = fn.expand('%:e')
    local modified_str

    local icon = component.icon or
        require('nvim-web-devicons').get_icon(filename, extension, { default = true })

    if filename == '' then filename = 'unnamed' end

    if bo.modified then
        local modified_icon = component.file_modified_icon or '●'
        modified_str = modified_icon .. ' '
    else
        modified_str = ''
    end

    return icon .. ' ' .. filename .. ' ' .. modified_str
end

function M.file_size()
    local suffix = {'b', 'k', 'M', 'G', 'T', 'P', 'E'}
    local index = 1

    local fsize = fn.getfsize(fn.expand('%:p'))

    while fsize > 1024 and index < 7 do
        fsize = fsize / 1024
        index = index + 1
    end

    return string.format('%.2f', fsize) .. suffix[index]
end

function M.file_type()
    return bo.filetype:upper()
end

function M.file_encoding()
    local enc = (bo.fenc ~= '' and bo.fenc) or o.enc
    return enc:upper()
end

return M
