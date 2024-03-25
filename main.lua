require('src.constants')

love.graphics.setDefaultFilter("nearest", "nearest")

LEFT = 0
RIGHT = 1
GRAVITY = 1600

TILE_SIZE = 32
PLAYER_SCALE = 1.9

local logoDelay = DEBUG and 0 or 3
local logoTimer = logoDelay

-- Initialize variables
local player = require('src.player')
local projectiles = require('projectiles')
local Layer = require('src.drawing.layer')
local Pickable = require('src.pickable')
local Enemy = require('enemy')
local collision = require('src.collision')
local GameObjects = require('src.system.gameobjects')
local Exit = require('src.exit')
local timer = require('src.system.timer')

-- library code
local ldtk = require('libs.ldtk')
local inspect = require('libs.inspect')
local wf = require('libs/windfield')
World = wf.newWorld(0, GRAVITY)

-- vars

local ldtkPath = 'tilemaps/ldtk/drakeshot.ldtk'

function love.load()
    ldtk:load(ldtkPath)
    ldtk:setFlipped(true)
    -- load dependencies
    -- submodule Simple-Tiled-Implementation
    local hump = require('libs/camera')
    Anim8 = require('libs/anim8')

    -- game maps/tiles
    Camera = hump()
    Camera:zoomTo(2)

    World:addCollisionClass(Colliders.PLATFORMS)
    World:addCollisionClass(Colliders.CONSUMABLE)
    World:addCollisionClass(Colliders.ENEMY)
    World:addCollisionClass(Colliders.GROUND)
    World:addCollisionClass(Colliders.BULLETS, { ignores = { Colliders.PLATFORMS } })
    World:addCollisionClass(Colliders.PLAYER, { ignores = { Colliders.BULLETS } })
    World:addCollisionClass(Colliders.GHOST, {
        ignores = {
            Colliders.CONSUMABLE,
            Colliders.ENEMY,
            Colliders.GROUND,
            Colliders.PLATFORMS,
            Colliders.BULLETS,
            Colliders.PLAYER }
    })
    World:addCollisionClass(Colliders.GOAL, { ignores = { Colliders.PLAYER } }
    )

    SFX = require('audio')
    SFX.DrWeeb:setLooping(true)
    SFX.DrWeeb:play()

    ldtk:level('Level_0')
end

function love.update(dt)
    timer.update(dt)

    if logoTimer > 0 then logoTimer = logoTimer - dt end

    World:update(dt)
    player.UpdatePlayer(dt)
    GameObjects.update_all(dt)
    projectiles.Shoot(dt,
        player.x,
        player.y - (player.height / 2),
        player.facing,
        player.dead
    )
    player.Jump()

    projectiles.Update(dt)

    -- TODO: lerp cam to player
    Camera:lookAt(
        player.x + player.width / 2,
        player.y - player.height / 2)
end

function love.keyreleased(key)
    if key == "escape" then
        love.event.quit()
    end
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
    GameObjects.draw_all()

    if DEBUG then World:draw() end

    -- Draw the player
    -- Enemy.DrawEnemies()
    player.Draw()
    projectiles.DrawBullets()

    love.graphics.setColor(1, 1, 1)

    -- pickable
    -- Pickable.Draw()
    Camera:detach()
    local items = player.inventory:find(Items.MONEY)
    local gil = 0
    if items then
        for _, i in ipairs(items) do
            gil = gil + i.value
        end
    end
    love.graphics.print("HP: " .. player.hp, 10, 10)
    love.graphics.print("GIL: " .. gil, 10, 30)
    love.graphics.print("Arrow keys: move", 10, 100)
    love.graphics.print("Left control: shoot", 10, 120)
    love.graphics.print("Space: jump", 10, 140)
    love.graphics.print("Goal: get the money and run", 10, 170)
    local logo = love.graphics.newImage('sprites/logo.png')

    if player.win then
        love.graphics.print("WIN", 300, 300)
    elseif player.dead then
        love.graphics.print("DED", 300, 300)
    end

    if logoTimer > 0 then
        local sx = love.graphics.getWidth() / logo:getWidth()
        local sy = love.graphics.getHeight() / logo:getHeight()

        love.graphics.draw(
            logo,
            0, 0, 0, sx, sy)
    end
end

function ldtk.onLayer(layer)
    -- Here we treated the layer as an object and added it to the table we use to draw.
    -- Generally, you would create a new object and use that object to draw the layer.
    GameObjects.add(Layer(layer)) --adding layer to the table we use to draw
end

local playerStartX, playerStartY
local goal

function ldtk.onEntity(entity)
    print(string.format('entity id:%s x:%s y:%s width:%s height:%s props:%s visible:%s',
        entity.id, entity.x, entity.y, entity.width, entity.height,
        inspect(entity.props), tostring(entity.visible)))

    if entity.id == 'Enemy' then
        local w = Enemy.New(entity)
        GameObjects.add(w)
    elseif entity.id == 'Start' then
        playerStartX, playerStartY = entity.x, entity.y
        -- GameObjects.add(s)
    elseif entity.id == Items.EXIT then
        local goal = Exit.New(entity)
        GameObjects.add(goal)
    elseif entity.props[EntityProps.PICKABLE] then
        local g = Pickable.New(entity)
        GameObjects.add(g)
    end

    if playerStartX and playerStartY and not player.initialized then
        player.InitPlayer(PLAYER_SCALE, PLAYER_SCALE, goal, playerStartX, playerStartY)
    end
end

function ldtk.onLevelLoaded(level)
    --removing all objects so we have a blank level
    GameObjects.reset()

    --changing background color to the one defined in LDtk
    love.graphics.setBackgroundColor(level.backgroundColor)

    --draw a bunch of rectangles
    collision:new(level, ldtkPath)
    collision:loadJSON()

    -- platform tiles
    collision:IntGridToWinfieldRects_Merged(collision:findIntGrid('PlatformGrid'), Colliders.PLATFORMS,
        TILE_SIZE)
    -- ground tiles
    collision:IntGridToWinfieldRects(collision:findIntGrid('IntGrid'), Colliders.GROUND, TILE_SIZE)
end
