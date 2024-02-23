module('projectiles', package.seeall)

-- Initialize a table to store bullets
local bullets = {}
local icePlatforms = {}

BULLET_SPEED = 600
local shootDelay = 1  -- Delay in seconds
local shootTimer = shootDelay
local cleanDelay = 20 -- Delay in seconds
local cleanTimer = cleanDelay
local meltDelay = 10
local image = love.graphics.newImage('sprites/ice-spike-1.png')

local theWastelandOfDeadBullets = -9999


-- Define the Projectile class
Bullet = {}
Bullet.__index = Bullet
function Bullet.new(x, y, direction)
    local self = setmetatable({}, Bullet)
    self.x = x
    self.y = y
    self.width = image:getWidth()
    self.height = image:getHeight()
    self.direction = direction
    self.state = 'flying'
    self.deleted = false
    self.collider = World:newBSGRectangleCollider(
        self.x,
        self.y,
        self.width + 10,
        self.height,
        0)
    self.collider:setCollisionClass('Bullet')
    self.collider:setGravityScale(0)
    self.collider:setFixedRotation(true)
    self.collider:setObject(self)
    return self
end

local function checkCollisionWithWall(bullet, idx)
    if bullet.collider:enter('Wall') then
        print(bullet.collider, ' hit a wall!')
        bullet.state = 'stuck'
        bullet.collider:setType('static')
        bullet.collider:setCollisionClass('Platform')
        bullet.meltTimer = meltDelay
        SFX.IceSpikeLand:play()
    end
end

local function move(dt)
    -- Update existing bullets (move them forward)
    for _, bullet in pairs(bullets) do
        if bullet.state ~= 'stuck' then
            if bullet.direction == LEFT then
                bullet.x = bullet.x + dt * -BULLET_SPEED
            else
                bullet.x = bullet.x + dt * BULLET_SPEED
            end
            bullet.collider:setX(bullet.x)
            bullet.collider:setY(bullet.y)

            -- keep it from moving on y axis
            local vx, _ = bullet.collider:getLinearVelocity()
            bullet.collider:setLinearVelocity(vx, 0)

            -- Check for collision with a wall (you'll need to implement this)
            checkCollisionWithWall(bullet)
        end
    end
end

local function iceMelt(dt)
    -- clean up static spikes
    for i, spike in ipairs(bullets) do
        if spike.state == 'stuck' then
            spike.meltTimer = spike.meltTimer - dt
            if spike.meltTimer <= 0 then
                MeltBullet(spike, i)
                return
            end
        end
    end
end

local function cleanUpBullets(dt)
    cleanTimer = cleanTimer - dt
    if cleanTimer > 0 then return end

    local colliders = World:queryCircleArea(theWastelandOfDeadBullets, theWastelandOfDeadBullets, 300)
    for _, collider in ipairs(colliders) do
        print('delete bullet collider ', collider.id)
        print(pcall(function() collider:destroy() end))
    end
    cleanTimer = cleanDelay
end

function Update(dt)
    move(dt)
    iceMelt(dt)
    cleanUpBullets(dt)
end

function NumBullets()
    local size = 0
    for _ in pairs(bullets) do size = size + 1 end
    return size
end

function DeleteBullet(bullet, idx)
    local trackingTable = bullets

    table.remove(trackingTable, idx)
    bullet.collider:setCollisionClass('Ghost')
    bullet.x = theWastelandOfDeadBullets
    bullet.y = theWastelandOfDeadBullets
    pcall(function()
        bullet.collider:setX(bullet.x)
        bullet.collider:setY(bullet.y)
    end)
end

function MeltBullet(bullet, idx)
    print('melt bullet ', idx)
    DeleteBullet(bullet, idx)
end

function Shoot(dt, x, y, playerFacing)
    -- Decrease the timer
    shootTimer = shootTimer - dt

    -- Handle shooting (you can trigger this based on player input)
    if love.keyboard.isDown('lctrl') and shootTimer <= 0 then
        -- Spawn a bullet at player's position
        SFX.ShootProjectile:play()
        SpawnBullet(x, y + 30, playerFacing)
        -- reset timer
        shootTimer = shootDelay
    end
end

function DrawBullets()
    -- Draw bullets (you can replace this with your actual bullet drawing code)
    love.graphics.setColor(1, 1, 1)
    for _, bulSpikes in pairs({ bullets, icePlatforms }) do
        for _, bullet in ipairs(bulSpikes) do
            -- Assuming bullet size
            love.graphics.draw(
                image,
                bullet.x - bullet.width / 2,
                bullet.y - bullet.height / 2,
                0)
        end
    end
end

function SpawnBullet(x, y, direction)
    table.insert(bullets, Bullet.new(x, y, direction))
end
