module('projectiles', package.seeall)

-- Initialize a table to store bullets
local bullets = {}
local icePlatforms = {}

BULLET_SPEED = 600
local shootDelay = 1 -- Delay in seconds
local shootTimer = shootDelay
local image = love.graphics.newImage('sprites/ice-spike-1.png')


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
    self.meltTimer = 10 -- seconds til melt
    return self
end

function NumBullets()
    local size = 0
    for _ in pairs(bullets) do size = size + 1 end
    return size
end

function DeleteBullet(bullet, idx, melted)
    local trackingTable = bullets
    if melted then
        trackingTable = icePlatforms
    end

    table.remove(trackingTable, idx)
    bullet.collider:setCollisionClass('Ghost')
    bullet.x = love.graphics.getWidth() / 2
    bullet.y = love.graphics.getHeight() / 3
    pcall(function()
        bullet.collider:setX(bullet.x)
        bullet.collider:setY(bullet.y)
    end)
end

function MeltBullet(bullet, idx)
    print('melt bullet ', idx)
    DeleteBullet(bullet, idx, true)
end

local function checkCollisionWithWall(bullet, idx)
    if bullet.collider:enter('Wall') then
        print(bullet.collider, ' hit a wall!')
        bullet.state = 'stuck'
        bullet.collider:setType('static')
        bullet.collider:setCollisionClass('Platform')
        table.insert(icePlatforms, bullet)
        table.remove(bullets, idx)
    end
end

function Shoot(dt, x, y, playerFacing)
    -- Decrease the timer
    shootTimer = shootTimer - dt

    -- Handle shooting (you can trigger this based on player input)
    if love.keyboard.isDown('lctrl') and shootTimer <= 0 then
        -- Spawn a bullet at player's position
        SpawnBullet(x, y + 30, playerFacing)
        -- reset timer
        shootTimer = shootDelay
    end
end

function DrawBullets()
    -- Draw bullets (you can replace this with your actual bullet drawing code)
    -- Set bullet color to red
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
    -- if NumBullets() > 3 then
    --     print('full array, delete first')
    --     DeleteBullet(bullets[1], 1)
    -- end
    table.insert(bullets, Bullet.new(x, y, direction))
end

function Update(dt)
    -- Update existing bullets (move them forward)
    for i, bullet in ipairs(bullets) do
        if bullet.state == 'flying' then
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

            -- Remove bullets that go off-screen
            if bullet.collider:getX() > love.graphics.getWidth() + Camera.x + 10 then
                DeleteBullet(bullet, i)
                return
            end

            -- Check for collision with a wall (you'll need to implement this)
            checkCollisionWithWall(bullet)
        end
    end

    for i, spike in ipairs(icePlatforms) do
        spike.meltTimer = spike.meltTimer - dt
        -- Delete melted bullets
        if spike.meltTimer <= 0 then
            MeltBullet(spike, i)
            return
        end
    end
end

function CleanUpBullets()
    for _, bulSpikes in pairs({ bullets, icePlatforms }) do
        for _, bullet in ipairs(bulSpikes) do
            if bullet.deleted then
                local success, err = pcall(function() bullet.collider:destroy() end)
                if not success then
                    print(err)
                end
            end
        end
    end
end
