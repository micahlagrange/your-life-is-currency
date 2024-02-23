module('enemy', package.seeall)

local spritesheet = require('spritesheet')

OBJECT_LAYER_ENEMIES = 'Enemy'
ENEMY_SPEED = 8000
ENEMY_SCALE = 1.9
MAX_ENEMY_SPEED = 100

local flipDelay = 2
local walkDelay = 2
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

    obj.image = love.graphics.newImage('sprites/fireguy-anims.png')
    obj.grid = spritesheet.NewAnim8Grid(obj.image, TILE_SIZE, TILE_SIZE)
    obj.animations = {}
    obj.animations.idle = Anim8.newAnimation(obj.grid('1-6', 1), 0.2)
    obj.animations.walk = Anim8.newAnimation(obj.grid('1-4', 2), 0.2)
    obj.animations.attac = Anim8.newAnimation(obj.grid('1-5', 3), 0.1, function() obj:resetAnim() end)
    obj.animations.frozen = Anim8.newAnimation(obj.grid('1-1', 4), 0.5, 'pauseAtEnd')
    obj.animations.ded = Anim8.newAnimation(obj.grid('2-3', 4), 0.3, 'pauseAtEnd')
    obj.currentAnim8 = obj.animations.walk

    obj.x = x
    obj.y = y
    obj.scaleX, obj.scaleY = ENEMY_SCALE, ENEMY_SCALE
    obj.w = TILE_SIZE * ENEMY_SCALE
    obj.h = TILE_SIZE * ENEMY_SCALE
    obj.collider = obj:newCollider()

    obj.flipTimer = flipDelay
    obj.walkTimer = walkDelay
    obj.resting = false

    return obj
end

function Enemy:attak(player)
    if self.frozen then return false end

    if player.x > self.x then
        self.facing = RIGHT
    else
        self.facing = LEFT
    end

    self.currentAnim8 = self.animations.attac
    return true
end

function Enemy:resetAnim()
    print('resetted')
    self.currentAnim8 = self.animations.idle
end

function Enemy:flipFacing()
    if self.facing == RIGHT then
        self.facing = LEFT
    elseif self.facing == LEFT then
        self.facing = RIGHT
    end
end

function Enemy:freeze()
    if self.dead then return end

    self.currentAnim8 = self.animations.frozen
end

function Enemy:hit(isBullet)
    if self.frozen then
        self.currentAnim8 = self.animations.ded
        self.dead = true
        self.collider:setCollisionClass('Ghost')
    else
        if isBullet then
            self.frozen = true
        end
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

function Enemy:checkCollision()
    if self.collider:enter('Bullet') then
        self:hit(true)
        self:freeze()
    elseif self.collider:enter('Player') then
        self:hit(false)
    end
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
    self.currentAnim8:draw(
        self.image,
        adjustedX - self.width / 2,
        self.y - self.height / 2,
        0,
        scaleX,
        self.scaleY)
end

function Enemy:restOrWalk()
    if self.resting == true then
        self.resting = false
    else
        self.resting = true
    end
    self.walkTimer = walkDelay
end

function Enemy:chooseConstantAnimation(velocity)
    if self.dead then return end

    if self.currentAnim8 ~= self.animations.walk
        and self.currentAnim8 ~= self.animations.idle then
        return
    end
    if velocity == 0 then
        self.currentAnim8 = self.animations.idle
    else
        self.currentAnim8 = self.animations.walk
    end
end

function Enemy:update(dt)
    self:checkCollision()

    local px = self.collider:getLinearVelocity()

    self:chooseConstantAnimation(px)
    self.currentAnim8:update(dt)

    if self.dead or self.frozen then return end

    -- back and forth
    self.flipTimer = self.flipTimer - dt
    self.walkTimer = self.walkTimer - dt

    if px == 0 and self.flipTimer <= 0 then
        self:flipFacing()
        self.flipTimer = flipDelay
    end

    if self.walkTimer <= 0 then
        self:restOrWalk()
    end

    if self.resting then return end

    -- Check keyboard input
    if self.facing == RIGHT and px < MAX_ENEMY_SPEED then
        self.collider:applyForce(ENEMY_SPEED, 0)
    elseif self.facing == LEFT and px > -MAX_ENEMY_SPEED then
        self.collider:applyForce(-ENEMY_SPEED, 0)
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
