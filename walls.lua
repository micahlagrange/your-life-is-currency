module('walls', package.seeall)

local walls = {}
local platforms = {}

function GenerateWalls()
    if GameMap.layers['Wall'] then
        for i, obj in pairs(GameMap.layers['Wall'].objects) do
            local wall = World:newRectangleCollider(obj.x, obj.y, obj.width, obj.height)
            wall:setType('static')
            wall:setCollisionClass('Wall')
            table.insert(walls, wall)
        end
    end
end

function GeneratePlatforms()
    if GameMap.layers['Platform'] then
        for i, obj in pairs(GameMap.layers['Platform'].objects) do
        local platform = World:newRectangleCollider(obj.x, obj.y, obj.width, obj.height)
        platform:setType('static')
        platform:setCollisionClass('Platform')
        platform:setObject(obj)
        table.insert(platforms, platform)
        end
    end
end
