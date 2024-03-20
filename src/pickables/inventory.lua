local object = require('libs.classic')
local inventory = object:extend()

function inventory:new()
    self.container = {}
end

function inventory:add(item)
    table.insert(self.container, item)
end

function inventory:find(name)
    local found = {}

    for _, i in pairs(self.container) do
        if i.name == name then
            table.insert(found, i)
        end
    end
    return found
end

function inventory:findQuantityOf(name)
    local val = 0
    for _, i in ipairs(self:find(name)) do
        val = val + i.value
        print(val)
    end
    return val
end

return inventory
