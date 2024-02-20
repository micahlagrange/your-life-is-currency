io.stdout:setvbuf("no")

-- Initialize variables
local player = require('player')
local projectiles = require('projectiles')
local walls = require('walls')

LEFT = 0
RIGHT = 1
GRAVITY = 1600

function love.load(args)
    -- load dependencies
    -- submodule Simple-Tiled-Implementation
    local sti = require('vendor/Simple-Tiled-Implementation/sti')
    local hump = require('vendor/hump/camera')
    local wf = require('vendor/windfield/windfield')

    -- game maps/tiles
    GameMap = sti('tilemaps/testMap.lua')
    Camera = hump()
    World = wf.newWorld(0, GRAVITY)

    World:addCollisionClass('Platform')
    World:addCollisionClass('Player')

    -- Set the player's initial position at the middle of the screen
    player.Props.x = love.graphics.getWidth() / 2
    player.Props.y = love.graphics.getHeight() / 3
    player.InitPlayer(.3, .3)

    -- make walls
    walls.GenerateWalls()
end

function love.update(dt)
    World:update(dt)
    player.Move(dt)
    player.Jump()
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
    --sky blue
    love.graphics.setColor(0.52, 0.80, 0.92)
    love.graphics.rectangle(
        'fill', 0, 0,
        love.graphics.getWidth(),
        love.graphics.getHeight())

    Camera:attach()
    -- reset color, Draw the tilemap
    love.graphics.setColor(1, 1, 1)
    GameMap:drawLayer(GameMap.layers['Ground'])
    GameMap:drawLayer(GameMap.layers['Platforms'])

    -- World:draw()
    -- Draw the player
    player.Draw()
    projectiles.DrawBullets()
    Camera:detach()

    love.graphics.print("hello", 10, 10)
end
