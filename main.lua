io.stdout:setvbuf("no")

-- Initialize variables
local platform = {}

local player = require('player')
local projectiles = require('projectiles')

function love.load(args)
    -- Set up the platform
    platform.width = love.graphics.getWidth()
    platform.height = love.graphics.getHeight() / 2
    platform.x = 0
    platform.y = platform.height

    -- Load the player image
    PlayerLuaImage = love.graphics.newImage(player.Props.imagePath)
    -- Set the player's initial position at the middle of the screen
    player.Props.x = love.graphics.getWidth() / 2
    player.Props.y = love.graphics.getHeight() / 2
end

function love.update(dt)
    player.Move(dt)
    player.Jump(dt)
    projectiles.Shoot(dt, player.Props.x, player.Props.y)
end

function love.draw()
    -- Draw the platform
    love.graphics.setColor(1, 1, 1)
    love.graphics.rectangle('fill', platform.x, platform.y, platform.width, platform.height)

    -- Draw the player
    love.graphics.setColor(0.6, 0.2, 0.8)
    love.graphics.draw(PlayerLuaImage, player.Props.x, player.Props.y)

    projectiles.DrawBullets()
end
