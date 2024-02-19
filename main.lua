io.stdout:setvbuf("no")

-- Initialize variables
local player = require('player')
local projectiles = require('projectiles')

LEFT = 0
RIGHT = 1

function love.load(args)
    -- load dependencies
    -- submodule Simple-Tiled-Implementation
    Sti = require('vendor/Simple-Tiled-Implementation/sti')
    Hump = require('vendor/hump/camera')
    Camera = Hump()

    -- Set the player's initial position at the middle of the screen
    player.Props.x = love.graphics.getWidth() / 2
    player.Props.y = love.graphics.getHeight() / 3
    player.SetDimensions(.5, .5)

    -- game maps/tiles
    GameMap = Sti('tilemaps/testMap.lua')
end

function love.update(dt)
    player.Move(dt)
    player.Jump(dt)
    projectiles.Shoot(dt,
        player.Props.x,
        player.Props.y - player.Props.height / 2,
        player.Props.facing
    )

    -- lerp cam to player
    Camera:lookAt(
        player.Props.x + player.Props.width / 2,
        player.Props.y - player.Props.height / 2)
end

function love.draw()
    Camera:attach()
    --sky blue
    love.graphics.setColor(0.52, 0.80, 0.92)
    love.graphics.rectangle(
        'fill', 0, 0,
        love.graphics.getWidth(),
        love.graphics.getHeight())

    -- reset color, Draw the tilemap
    love.graphics.setColor(1, 1, 1)
    GameMap:drawLayer(GameMap.layers['Ground'])
    GameMap:drawLayer(GameMap.layers['Platforms'])

    -- Draw the player
    love.graphics.draw(
        player.Props.image,
        player.Props.x,
        player.Props.y - player.Props.height,
        0,
        player.Props.scaleX,
        player.Props.scaleY)

    projectiles.DrawBullets()
    Camera:detach()

    love.graphics.print("hello", 10, 10)
end
