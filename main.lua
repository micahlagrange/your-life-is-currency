io.stdout:setvbuf("no")

-- Initialize variables
local platform = {}

function love.load(args)
    -- Set up the platform
    platform.width = love.graphics.getWidth()
    platform.height = love.graphics.getHeight() / 2
    platform.x = 0
    platform.y = platform.height

    -- Load the player image (replace 'path/to/your/playerImage.png' with the actual path)
    playerImage = love.graphics.newImage('inevitable-brew.icon.png')

    -- Set the player's initial position at the middle of the screen
    player.x = love.graphics.getWidth() / 2
    player.y = love.graphics.getHeight() / 2
end

function love.update(dt)
    player.move(dt)
    player.jump(dt)
    projectiles.shoot(dt)
end

function love.draw()
    -- Draw the platform
    love.graphics.setColor(1, 1, 1)
    love.graphics.rectangle('fill', platform.x, platform.y, platform.width, platform.height)

    -- Draw the player
    love.graphics.setColor(0.6, 0.2, 0.8)
    love.graphics.draw(playerImage, player.x, player.y)

    projectiles.drawBullets()
end
