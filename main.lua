io.stdout:setvbuf("no")

-- Initialize variables
local player = require('player')
local projectiles = require('projectiles')

LEFT = 0
RIGHT = 1

function love.load(args)
    -- load dependencies
    -- submodule Simple-Tiled-Implementation
    local sti = require('vendor/Simple-Tiled-Implementation/sti')
    local hump = require('vendor/hump/camera')
    local wf = require('vendor/windfield')

    -- game maps/tiles
    GameMap = sti('tilemaps/testMap.lua')
    Camera = hump()
    World = wf.newWorld()

    -- Set the player's initial position at the middle of the screen
    player.Props.x = love.graphics.getWidth() / 2
    player.Props.y = love.graphics.getHeight() / 3
    player.InitPlayer(.5, .5,
        World:newRectangleCollider(
            player.Props.x,
            player.Props.y,
            player.Props.width,
            player.Props.height))
end

function love.update(dt)
    World:update()
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
    World:draw()
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
    player.Draw()
    projectiles.DrawBullets()
    Camera:detach()

    love.graphics.print("hello", 10, 10)
end
