local projectiles {}

-- Initialize a table to store bullets
local bullets = {}
local bulletSpeed = 2000

function projectiles.shoot(dt)
    -- Handle shooting (you can trigger this based on player input)
    if love.keyboard.isDown('lctrl') then
        spawnBullet(player.x, player.y)  -- Spawn a bullet at player's position
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

function projectiles.drawBullets()
    -- Draw bullets (you can replace this with your actual bullet drawing code)
    love.graphics.setColor(1, 0, 0)  -- Set bullet color to red
    for _, bullet in ipairs(bullets) do
        love.graphics.circle('fill', bullet.x, bullet.y, 5)  -- Assuming bullet size
    end
end

function projectiles.spawnBullet(x, y)
    local bullet = { x = x, y = y }
    table.insert(bullets, bullet)
end
