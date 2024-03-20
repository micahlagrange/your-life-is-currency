local spritesheet = require('spritesheet')

local object = require('libs.classic')
local the3DPyramidThingImage = love.graphics.newImage('sprites/cash.png')
local money = object:extend()

function money:new(entity)
    self.name = Items.MONEY
    self.grid = spritesheet.NewAnim8Grid(the3DPyramidThingImage, TILE_SIZE, TILE_SIZE)
    self.anim = Anim8.newAnimation(self.grid('1-1', 1), 0.2)
    self.value = entity.props[EntityProps.VALUE]
    self.x, self.y = entity.x, entity.y
end

function money:update(dt)
end

function money:draw()
    self.anim:draw(the3DPyramidThingImage, self.x, self.y, 0, 1, 1)
end

return money
