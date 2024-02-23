module('enemy', package.seeall)

local spritesheet = require('spritesheet')

local hotSpriteSheetPath = 'sprites/fireguy.png'
local frozenSpriteSheetPath = 'sprites/frozenguy.png'

OBJECT_LAYER_ENEMIES = 'Enemy'
ENEMY_SPEED = 8000
ENEMY_SCALE = 1.9
MAX_ENEMY_SPEED = 60

local flipDelay = 2
local enemies = {}

Enemy = {
    frozen = false,
    height = TILE_SIZE * ENEMY_SCALE,
    width = TILE_SIZE * ENEMY_SCALE,
    facing = LEFT
}
function Enemy:new(x, y, obj)
    obj = obj or {}
    setmetatable(obj, self)
    self.__index = self

    obj.hotImage = love.graphics.newImage(hotSpriteSheetPath)
    obj.frozenImage = love.graphics.newImage(frozenSpriteSheetPath)
    obj.hotQuads = spritesheet.SpriteSheetToQuads(obj.hotImage, TILE_SIZE, TILE_SIZE)
    obj.frozenQuads = spritesheet.SpriteSheetToQuads(obj.frozenImage, TILE_SIZE, TILE_SIZE)
    obj.image = obj.hotImage
    obj.quads = obj.hotQuads
    obj.currentSprite = 1

    obj.x = x
    obj.y = y
    obj.scaleX, obj.scaleY = ENEMY_SCALE, ENEMY_SCALE
    obj.w = TILE_SIZE * ENEMY_SCALE
    obj.h = TILE_SIZE * ENEMY_SCALE
    obj.collider = obj:newCollider()

    obj.flipTimer = flipDelay

    return obj
end

function Enemy:flipFacing()
    if self.facing == RIGHT then
        print('flip left')
        self.facing = LEFT
    elseif self.facing == LEFT then
        print('flip right')
        self.facing = RIGHT
    end
end

function Enemy:freeze()
    self.frozen = true
end

function Enemy:hit()
    if self.frozen then
        self.image = self.frozenImage
        self.quads = self.frozenQuads
    end
end

function Enemy:newCollider()
    local collider = World:newBSGRectangleCollider(
        self.x,
        self.y,
        self.w,
        self.h,
        15 -- enemies be rounder
    )
    collider:setCollisionClass('Enemy')
    collider:setObject(self)
    collider:setFixedRotation(true)
    collider:setX(self.x)
    collider:setY(self.y)
    return collider
end

function Enemy:draw()
    local scaleX
    local adjustedX

    if self.facing == RIGHT then
        scaleX = self.scaleX
        adjustedX = self.x
    else
        -- players origin is their left side, so when the image
        -- flips we need to push them right
        adjustedX = self.x + self.width
        scaleX = -self.scaleX
    end

    love.graphics.setColor(1, 1, 1)
    love.graphics.draw(
        self.image,
        self.quads[self.currentSprite],
        adjustedX - self.width / 2,
        self.y - self.height / 2,
        0,
        scaleX,
        self.scaleY)
end

function Enemy:update(dt)
    local px = self.collider:getLinearVelocity()

    -- back and forth
    self.flipTimer = self.flipTimer - dt
    if px == 0 and self.flipTimer <= 0 then
        self:flipFacing()
        self.flipTimer = flipDelay
    end

    -- Check keyboard input
    if self.facing == RIGHT and px < MAX_ENEMY_SPEED then
        self.collider:applyForce(ENEMY_SPEED, 0)
        -- self.facing = RIGHT
    elseif self.facing == LEFT and px > -MAX_ENEMY_SPEED then
        self.collider:applyForce(-ENEMY_SPEED, 0)
        -- self.facing = LEFT
    end
    -- Update player position based on collider
    self.x, self.y = self.collider:getX(), self.collider:getY()
end

function GenerateEnemies()
    if GameMap.layers[OBJECT_LAYER_ENEMIES] then
        for i, obj in pairs(GameMap.layers[OBJECT_LAYER_ENEMIES].objects) do
            table.insert(enemies, Enemy:new(obj.x, obj.y))
        end
        for i, obj in ipairs(enemies) do
            print('new enemy ', obj.x, 'x', obj.y)
        end
    end
end

function DrawEnemies()
    for _, e in ipairs(enemies) do
        e:draw()
    end
end

function UpdateEnemies(dt)
    for _, e in ipairs(enemies) do
        e:update(dt)
    end
end
