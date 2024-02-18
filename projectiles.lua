module('projectiles', package.seeall)

-- Initialize a table to store bullets
local bullets = {}
local bulletSpeed = 2000
local bulletDelay = 0.5 -- Delay in seconds
local bulletTimer = bulletDelay

function Shoot(dt, x, y)
    -- Decrease the timer
    bulletTimer = bulletTimer - dt


    -- Handle shooting (you can trigger this based on player input)
    if love.keyboard.isDown('lctrl') and bulletTimer <= 0 then
        -- Spawn a bullet at player's position
        SpawnBullet(x, y)
        -- reset timer
        bulletTimer = bulletDelay
    end

    -- Update existing bullets (move them forward)
    for i, bullet in ipairs(bullets) do
        bullet.x = bullet.x + bulletSpeed * dt
        -- Remove bullets that go off-screen
        if bullet.x > love.graphics.getWidth() + 100 then
            table.remove(bullets, i)
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

function SpawnBullet(x, y)
    table.insert(bullets, { x = x, y = y })
end
