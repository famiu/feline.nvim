local M = {}

local component_name_cache = {}

local function wrap_component(component, indices)
    local component_mt = {}
    component_mt.__metatable = false
    component_mt._t = {}

    component_mt.__index = component_mt._t

    component_mt.__newindex = function(_, key, val)
        if key == 'name' then
            for k, v in pairs(component_name_cache) do
                if v[1] == indices[1] and v[2] == indices[2] and v[3] == indices[3] then
                    component_name_cache[k] = nil
                end
            end

            component_name_cache[val] = indices
        end

        component_mt._t[key] = val
    end

    local component_proxy = setmetatable({}, component_mt)

    for k, v in pairs(component) do
        component_proxy[k] = v
    end

    return component_proxy
end

local function wrap_section(section, indices)
    local section_mt = {}
    section_mt.__metatable = false
    section_mt._t = {}

    section_mt.__index = function(_, key)
        if key == 'get_components' then
            return function()
                return section_mt._t
            end
        else
            return section_mt._t[key]
        end
    end

    section_mt.__newindex = function(_, key, val)
        for k, v in pairs(component_name_cache) do
            if v[1] == indices[1] and v[2] == indices[2] and v[3] == key then
                component_name_cache[k] = nil
            end
        end

        section_mt._t[key] = wrap_component(val, {indices[1], indices[2], key})
    end

    local section_proxy = setmetatable({}, section_mt)

    for k, v in ipairs(section) do
        section_proxy[k] = v
    end

    return section_proxy
end

local function wrap_statusline_type(type, index)
    local type_mt = {}
    type_mt.__metatable = false
    type_mt._t = {}

    type_mt.__index = function(_, k)
        if k == 'get_sections' then
            return function()
                return type_mt._t
            end
        else
            return type_mt._t[k]
        end
    end

    type_mt.__newindex = function(_, key, val)
        for k, v in pairs(component_name_cache) do
            if v[1] == index and v[2] == key then
                component_name_cache[k] = nil
            end
        end

        type_mt._t[key] = wrap_section(val, {index, key})
    end

    local type_proxy = setmetatable({}, type_mt)

    for k, v in ipairs(type) do
        type_proxy[k] = v
    end

    return type_proxy
end

function M.wrap_components_table(components)
    local components_mt = {}
    components_mt.__metatable = false
    components_mt._t = {}

    components_mt.__index = function(_, key)
        if key == 'active' or key == 'inactive' then
            return components_mt._t[key]
        else
            local indices = component_name_cache[key]

            if indices then
                local type_name, section_index, component_index = unpack(indices)
                return components_mt._t[type_name][section_index][component_index]
            end
        end
    end

    components_mt.__newindex = function(_, key, val)
        if key == 'active' or key == 'inactive' then
            for k, v in pairs(component_name_cache) do
                if v[1] == key then
                    component_name_cache[k] = nil
                end
            end

            components_mt._t[key] = wrap_statusline_type(val, key)
        else
            local indices = component_name_cache[key]

            if indices then
                local type_name, section_index, component_index = unpack(indices)
                components_mt._t[type_name][section_index][component_index] = val
            end
        end
    end

    local components_table_proxy = setmetatable({}, components_mt)

    components_table_proxy.active = components.active
    components_table_proxy.inactive = components.inactive

    return components_table_proxy
end

return M