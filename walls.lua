module('walls', package.seeall)

local walls = {}

function GenerateWalls()
    if GameMap.layers['Walls'] then
        for i, obj in pairs(GameMap.layers['Walls'].objects) do
            local wall = World:newRectangleCollider(obj.x, obj.y, obj.width, obj.height)
            wall:setType('static')
            wall:setCollisionClass('Platform')
            table.insert(walls, wall)
        end
    end
end
