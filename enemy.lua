local spritesheet = require('spritesheet')
local object = require('libs.classic')

ENEMY_SPEED = 8000
ENEMY_SCALE = 1.9
MAX_ENEMY_SPEED = 100

local flipDelay = 2
local walkDelay = 2
local enemies = {}

-- Enemy = {
--     frozen = false,
--     height = TILE_SIZE * ENEMY_SCALE,
--     width = TILE_SIZE * ENEMY_SCALE,
--     facing = LEFT
-- }

local Enemy = {} -- module
local enemy = object:extend()


function Enemy.New(entity)
    return enemy(entity)
end

function enemy:new(entity)
    self.image = love.graphics.newImage('sprites/fireguy-anims.png')
    self.grid = spritesheet.NewAnim8Grid(self.image, TILE_SIZE, TILE_SIZE)
    self.animations = {}
    self.animations.idle = Anim8.newAnimation(self.grid('1-6', 1), 0.2)
    self.animations.walk = Anim8.newAnimation(self.grid('1-4', 2), 0.2)
    self.animations.attac = Anim8.newAnimation(self.grid('1-5', 3), 0.1, function() self:resetAnim() end)
    self.animations.frozen = Anim8.newAnimation(self.grid('1-1', 4), 0.5, 'pauseAtEnd')
    self.animations.ded = Anim8.newAnimation(self.grid('2-3', 4), 0.3, 'pauseAtEnd')
    self.currentAnim8 = self.animations.walk

    self.x = entity.x
    self.y = entity.y
    self.scaleX, self.scaleY = ENEMY_SCALE, ENEMY_SCALE
    self.width = TILE_SIZE * ENEMY_SCALE
    self.height = TILE_SIZE * ENEMY_SCALE
    self.collider = self:newCollider()

    self.flipTimer = flipDelay
    self.walkTimer = walkDelay
    self.resting = false
end

function enemy:attak(player)
    if self.frozen then return false end

    if player.x > self.x then
        self.facing = RIGHT
    else
        self.facing = LEFT
    end

    self.currentAnim8 = self.animations.attac
    return true
end

function enemy:resetAnim()
    print('resetted')
    self.currentAnim8 = self.animations.idle
end

function enemy:flipFacing()
    if self.facing == RIGHT then
        self.facing = LEFT
    elseif self.facing == LEFT then
        self.facing = RIGHT
    end
end

function enemy:freeze()
    if self.dead then return end

    self.currentAnim8 = self.animations.frozen
end

function enemy:hit(isBullet)
    if self.frozen then
        -- player or bullet kills
        self.currentAnim8 = self.animations.ded
        self.dead = true
        self.collider:setCollisionClass(Colliders.GHOST)
    else
        if isBullet then
            self.frozen = true
        end
    end
end

function enemy:newCollider()
    local collider = World:newCircleCollider(
        self.x,
        self.y,
        self.width / 2
    )
    collider:setCollisionClass(Colliders.ENEMY)
    collider:setObject(self)
    collider:setFixedRotation(true)
    collider:setX(self.x)
    collider:setY(self.y)
    return collider
end

function enemy:checkCollision()
    if self.collider:enter(Colliders.BULLETS) then
        self:hit(true)
        self:freeze()
    elseif self.collider:enter(Colliders.PLAYER) then
        self:hit(false)
    end
end

function enemy:draw()
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

function enemy:restOrWalk()
    if self.resting == true then
        self.resting = false
    else
        self.resting = true
    end
    self.walkTimer = walkDelay
end

function enemy:chooseConstantAnimation(velocity)
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

function enemy:update(dt)
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

-- function Enemy.GenerateEnemies()
--     if GameMap.layers[OBJECT_LAYER_ENEMIES] then
--         for i, obj in pairs(GameMap.layers[OBJECT_LAYER_ENEMIES].objects) do
--             table.insert(enemies, enemy:new(obj.x, obj.y))
--         end
--         for i, obj in ipairs(enemies) do
--             print('new enemy ', obj.x, 'x', obj.y)
--         end
--     end
-- end

function Enemy.DrawEnemies()
    for _, e in ipairs(enemies) do
        e:draw()
    end
end

function Enemy.UpdateEnemies(dt)
    for _, e in ipairs(enemies) do
        e:update(dt)
    end
end

return Enemy
