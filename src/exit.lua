local Exit = {}

local object = require('libs.classic')
local exit = object:extend()

function exit:new(collider, entity)
    self.collider = collider
    self.x = entity.x
    self.y = entity.y
    self.open = false
end

function exit:setOpen()
    self.collider:setX(self.x)
    self.collider:setY(self.y)
    self.open = true
end

function Exit.New(entity)
    local goal = World:newRectangleCollider(entity.x, entity.y, TILE_SIZE, TILE_SIZE)
    goal:setType('static')
    goal:setCollisionClass(Colliders.GOAL)
    goal:setX(-99999)
    goal:setY(-99999)
    return exit(goal, entity)
end

return Exit
