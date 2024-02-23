love.graphics.setDefaultFilter("nearest", "nearest")

LEFT = 0
RIGHT = 1
GRAVITY = 1600

LAYER_BG = 'Background'
LAYER_PLAYER = 'Player'
LAYER_FOREGROUND = 'Foreground'
TILE_SIZE = 32
PLAYER_SCALE = 1.9

-- Initialize variables
local player = require('player')
local projectiles = require('projectiles')
local walls = require('walls')
local pickable = require('pickable')
local enemy = require('enemy')

function love.load(args)
    -- load dependencies
    -- submodule Simple-Tiled-Implementation
    local hump = require('libs/camera')
    local sti = require('libs/sti')
    local wf = require('libs/windfield')
    Anim8 = require('libs/anim8')

    -- game maps/tiles
    GameMap = sti('tilemaps/toGoUpGoDown.lua')
    -- GameMap = sti('tilemaps/pipes.lu.lua')
    Camera = hump()
    Camera:zoomTo(2)
    World = wf.newWorld(0, GRAVITY)

    World:addCollisionClass('Platform')
    World:addCollisionClass('Pickable')
    World:addCollisionClass('Enemy')
    World:addCollisionClass('Wall')
    World:addCollisionClass('Bullet', { ignores = { 'Platform' } })
    World:addCollisionClass('Player', { ignores = { 'Bullet' } })
    World:addCollisionClass('Ghost', {
        ignores = {
            'Platform',
            'Player',
            'Bullet' }
    })
    World:addCollisionClass('END')

    local goal, goalx, goaly = walls.GenerateGoal()
    -- Set the player's initial position at the middle of the screen
    player.Props.x = love.graphics.getWidth() / 2
    player.Props.y = love.graphics.getHeight() / 3
    player.InitPlayer(PLAYER_SCALE, PLAYER_SCALE, goal, goalx, goaly)

    -- make walls and platforms
    walls.GenerateWalls()
    walls.GeneratePlatforms()
    pickable.GeneratePickables()
    enemy.GenerateEnemies()

    SFX = require('audio')
    SFX.DrWeeb:play()
end

function love.update(dt)
    World:update(dt)
    enemy.UpdateEnemies(dt)
    player.UpdatePlayer(dt)
    player.Jump()
    projectiles.Shoot(dt,
        player.Props.x,
        player.Props.y - (player.Props.height / 2),
        player.Props.facing,
        player.Props.dead
    )
    projectiles.Update(dt)

    -- TODO: lerp cam to player
    Camera:lookAt(
        player.Props.x + player.Props.width / 2,
        player.Props.y - player.Props.height / 2)

    -- pickables
    pickable.Update(dt)
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
    enemy.DrawEnemies()
    player.Draw()
    projectiles.DrawBullets()

    love.graphics.setColor(1, 1, 1)
    GameMap:drawLayer(GameMap.layers[LAYER_FOREGROUND])

    -- pickable
    pickable.Draw()
    Camera:detach()

    love.graphics.print("HP: " .. player.Props.hp, 10, 10)
    love.graphics.print("GIL: " .. player.Props.gil, 10, 30)

    if player.Props.win then
        love.graphics.print("WIN", 300, 300)
    elseif player.Props.dead then
        love.graphics.print("DED", 300, 300)
    end
end
