io.stdout:setvbuf("no")

-- Initialize variables
local player = require('player')
local projectiles = require('projectiles')
local walls = require('walls')

LEFT = 0
RIGHT = 1
GRAVITY = 1600

LAYER_BG = 'Background'
LAYER_PLAYER = 'Player'
LAYER_FOREGROUND = 'Foreground'

function love.load(args)
    -- load dependencies
    -- submodule Simple-Tiled-Implementation
    local sti = require('vendor/Simple-Tiled-Implementation/sti')
    local hump = require('vendor/hump/camera')
    local wf = require('vendor/windfield/windfield')

    -- game maps/tiles
    GameMap = sti('tilemaps/toGoUpGoDown.lua')
    -- GameMap = sti('tilemaps/pipes.lu.lua')
    Camera = hump()
    Camera:zoomTo(2)
    World = wf.newWorld(0, GRAVITY)

    World:addCollisionClass('Platform')
    World:addCollisionClass('Wall')
    World:addCollisionClass('Bullet', { ignores = { 'Platform' } })
    World:addCollisionClass('Player', { ignores = { 'Bullet' } })
    World:addCollisionClass('Ghost', {
        ignores = {
            'Platform',
            'Player',
            'Bullet' }
    })

    -- Set the player's initial position at the middle of the screen
    player.Props.x = love.graphics.getWidth() / 2
    player.Props.y = love.graphics.getHeight() / 3
    player.InitPlayer(1.9, 1.9)

    -- make walls and platforms
    walls.GenerateWalls()
    walls.GeneratePlatforms()
end

function love.update(dt)
    World:update(dt)
    player.Move(dt)
    player.Jump()
    projectiles.Shoot(dt,
        player.Props.x,
        player.Props.y - (player.Props.height / 2),
        player.Props.facing,
        player.Props.width
    )
    projectiles.Update(dt)

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
    GameMap:drawLayer(GameMap.layers[LAYER_BG])
    GameMap:drawLayer(GameMap.layers[LAYER_PLAYER])

    -- World:draw()
    -- Draw the player
    player.Draw()
    projectiles.DrawBullets()

    love.graphics.setColor(1, 1, 1)
    GameMap:drawLayer(GameMap.layers[LAYER_FOREGROUND])
    Camera:detach()

    love.graphics.print("hello", 10, 10)
end
