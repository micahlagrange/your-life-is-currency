local object      = require('libs.classic')
local spritesheet = require('spritesheet')

local Exit        = {}
local exit        = object:extend()

local exitImage   = love.graphics.newImage('sprites/door.png')
local scale       = 2

function exit:new(collider, entity)
    self.name = Colliders.EXIT
    self.grid = spritesheet.NewAnim8Grid(exitImage, TILE_SIZE, TILE_SIZE)
    self.anim = Anim8.newAnimation(self.grid('1-1', 1), 1)
    self.openanim = Anim8.newAnimation(self.grid('2-2', 1), 1)
    self.currentanim = self.anim
    self.collider = collider
    self.x = entity.x
    self.y = entity.y
    self.open = false
    self.goal = entity.props[EntityProps.GOAL]
end

function exit:update(dt)
    if self.collider:enter(Colliders.PLAYER) then
        local player = self.collider:getEnterCollisionData(Colliders.PLAYER).collider
        if player:getObject().inventory:findQuantityOf(Items.MONEY) >= self.goal then
            self.currentanim = self.openanim
        end
    end
end

function exit:draw()
    self.currentanim:draw(exitImage, self.x, self.y, 0, 2, 2)
end

function Exit.New(entity)
    local ext = World:newRectangleCollider(entity.x, entity.y, TILE_SIZE * scale, TILE_SIZE * scale)
    ext:setType('static')
    ext:setCollisionClass(Colliders.GOAL)
    ext:setX(entity.x + TILE_SIZE * scale / 2)
    ext:setY(entity.y + TILE_SIZE * scale / 2)
    return exit(ext, entity)
end

return Exit
