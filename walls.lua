module('walls', package.seeall)

local walls = {}
local platforms = {}

OBJECT_LAYER_WALLS = 'Wall'
OBJECT_LAYER_PLATFORMS = 'Platform'

function GenerateWalls()
    if GameMap.layers[OBJECT_LAYER_WALLS] then
        for i, obj in pairs(GameMap.layers[OBJECT_LAYER_WALLS].objects) do
            local wall = World:newRectangleCollider(obj.x, obj.y, obj.width, obj.height)
            wall:setType('static')
            wall:setCollisionClass('Wall')
            table.insert(walls, wall)
        end
    end
end

function GeneratePlatforms()
    if GameMap.layers[OBJECT_LAYER_PLATFORMS] then
        for i, obj in pairs(GameMap.layers[OBJECT_LAYER_PLATFORMS].objects) do
            local platform = World:newRectangleCollider(obj.x, obj.y, obj.width, obj.height)
            platform:setType('static')
            platform:setCollisionClass('Platform')
            platform:setObject(obj)
            table.insert(platforms, platform)
        end
    end
end

function GenerateGoal()
    if GameMap.layers['END'] then
        for i, obj in pairs(GameMap.layers['END'].objects) do
            local goal = World:newRectangleCollider(obj.x, obj.y, obj.width, obj.height)
            goal:setType('static')
            goal:setCollisionClass('END')
            goal:setX(-99999)
            goal:setY(-99999)
            return goal, obj.x, obj.y
        end
    end
end
