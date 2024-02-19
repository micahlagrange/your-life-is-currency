module('projectiles', package.seeall)

-- Initialize a table to store bullets
local bullets = {}
local bulletSpeed = 2000
local bulletDelay = 0.5 -- Delay in seconds
local bulletTimer = bulletDelay


-- Define the Projectile class
Bullet = {}
Bullet.__index = Bullet
function Bullet.new(x, y, direction)
    local self = setmetatable({}, Bullet)
    self.x = x
    self.y = y
    self.direction = direction
    self.state = 'flying'
    return self
end

local function checkCollisionWithWall()
    return false
end

function Shoot(dt, x, y, playerFacing)
    -- Decrease the timer
    bulletTimer = bulletTimer - dt

    -- Handle shooting (you can trigger this based on player input)
    if love.keyboard.isDown('lctrl') and bulletTimer <= 0 then
        -- Spawn a bullet at player's position
        SpawnBullet(x, y, playerFacing)
        -- reset timer
        bulletTimer = bulletDelay
    end

    -- Update existing bullets (move them forward)
    local vel
    for i, bullet in ipairs(bullets) do
        if bullet.state == 'flying' then
            if bullet.direction == LEFT then
                print('left')
                vel = -bulletSpeed * dt
            else
                print('right')
                vel = bulletSpeed * dt
            end
            bullet.x = bullet.x + vel
            -- Remove bullets that go off-screen
            if bullet.x > love.graphics.getWidth() + 100 then
                table.remove(bullets, i)
            end
            -- Check for collision with a wall (you'll need to implement this)
            if checkCollisionWithWall() then
                bullet.state = 'stuck'
            end
        end
    end
end

function DrawBullets()
    -- Draw bullets (you can replace this with your actual bullet drawing code)
    -- Set bullet color to red
    love.graphics.setColor(1, 0, 0)
    for _, bullet in ipairs(bullets) do
        -- Assuming bullet size
        love.graphics.circle('fill', bullet.x, bullet.y, 5)
    end
end

function SpawnBullet(x, y, direction)
    table.insert(bullets, Bullet.new(x, y, direction))
end
