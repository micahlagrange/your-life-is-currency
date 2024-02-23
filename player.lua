module('player', package.seeall)

local spritesheet = require('spritesheet')
local pickable = require('pickable')

-- Initialize player variables
Props = {
    x = 0,
    y = 0,
    -- Vertical velocity (initially zero)
    yVelocity = 0,
    -- Flag to check if the player is on the ground
    imagePath = 'sprites/icedragon-anims-lg.png',
    scaleX = 1,
    scaleY = 1,
    width = 1,
    height = 1,
    onGround = false,
    facing = LEFT,
    collider = nil,
    quads = nil,
    image = nil,
    currentSprite = 1,
    hp = 2,
    gil = 0,
    dead = false
}

-- Set player jump strength (adjust as needed)
PLAYER_SPEED = 8000
JUMP_STRENGTH = 4900
MAX_SPEED = 600
PLAYER_START = 'PlayerStart'
WIN_CONDITION = 3

local function preSolve(playerc, wallc, contact)
    if playerc.collision_class == 'Player'
        and
        wallc.collision_class == 'Platform'
    then
        local wallObj = wallc:getObject()
        local px, py = playerc:getPosition()
        local pw, ph = Props.width, Props.height
        local tx, ty = wallc:getPosition()
        local tw, th = wallObj.width, wallObj.height
        if py + ph / 2 > ty - th / 2 then
            contact:setEnabled(false)
        else
            Props.onGround = true
        end
    end
end

function Draw()
    local scaleX
    if Props.facing == RIGHT then
        scaleX = Props.scaleX
    else
        -- players origin is their left side, so when the image
        -- flips we need to push them right
        Props.x = Props.x + Props.width
        scaleX = -Props.scaleX
    end

    Props.currentAnim8:draw(
        Props.image,
        Props.x - Props.width / 2,
        Props.y - Props.height / 2,
        0,
        scaleX,
        Props.scaleY)
end

function Face(direction)
    Props.facing = direction
    if direction == LEFT then
        Props.currentSprite = 1
    else
        Props.currentSprite = 2
    end
end

local function resetAnim()
    Props.currentAnim8 = Props.animations.idle
end

local function chooseConstantAnimation(velocity)
    if Props.currentAnim8 ~= Props.animations.walk
        and Props.currentAnim8 ~= Props.animations.idle then
        return
    end
    if velocity == 0 then
        Props.currentAnim8 = Props.animations.idle
    else
        Props.currentAnim8 = Props.animations.walk
    end
end

local function hurt()
    local ec = Props.collider:getEnterCollisionData('Enemy')
    ec.collider:getObject():attak(Props)
    if Props.currentAnim8 == Props.animations.hurt then return end
    print('oof')
    Props.currentAnim8 = Props.animations.hurt
    Props.hp = Props.hp - 1
    if Props.hp <= 0 then
        Props.dead = true
        Props.currentAnim8 = Props.animations.ded
    end
end

function UpdatePlayer(dt)
    local px = Props.collider:getLinearVelocity()

    -- anim
    chooseConstantAnimation(px)
    Props.currentAnim8:update(dt)

    if Props.dead or Props.win then return end

    -- damage
    if Props.collider:enter('Enemy') then
        hurt()
    end

    -- Check keyboard input
    if love.keyboard.isDown('right') and px < MAX_SPEED then
        Props.collider:applyForce(PLAYER_SPEED, 0)
        Face(RIGHT)
    elseif love.keyboard.isDown('left') and px > -MAX_SPEED then
        Props.collider:applyForce(-PLAYER_SPEED, 0)
        Face(LEFT)
    end

    -- Update player position based on collider
    Props.x, Props.y = Props.collider:getX(), Props.collider:getY()

    if Props.collider:enter('Pickable') then
        local collided = Props.collider:getEnterCollisionData('Pickable')
        local pickup = collided.collider
        pickable.Pickup(pickup)
        if Props.gil >= WIN_CONDITION then
            print(Props.goal:getX())
            Props.goal:setX(Props.goalx)
            Props.goal:setY(Props.goaly)
            print(Props.goal:getX())
        end
    end

    if Props.collider:enter('END') then
        Props.win = true
    end
end

function Jump()
    if Props.collider:enter('Wall') then
        local collided = Props.collider:getEnterCollisionData('Wall')
        local platform = collided.collider

        if Props.y + Props.height / 2 < platform:getY() then
            Props.onGround = true
        end
    end
    if love.keyboard.isDown('space') and Props.onGround then
        Props.onGround = false
        local vx, vy = Props.collider:getLinearVelocity()
        Props.collider:setLinearVelocity(vx, 0)
        Props.collider:applyLinearImpulse(0, -JUMP_STRENGTH)
    end
end

function InitPlayer(scaleX, scaleY, goal, goalx, goaly)
    local playerWidth = 32  -- actual number of pixels wide for each sprite in the sprite sheet
    local playerHeight = 32 -- actual number of pixels high for each sprite in the sprite sheet

    Props.scaleX = scaleX
    Props.scaleY = scaleY
    Props.width = playerWidth * scaleX
    Props.height = playerWidth * scaleY

    Props.collider = World:newBSGRectangleCollider(
        player.Props.x,
        player.Props.y,
        player.Props.width,
        player.Props.height,
        5)
    Props.collider:setCollisionClass('Player')
    Props.collider:setFixedRotation(true)
    Props.collider:setPreSolve(preSolve)
    Props.image = love.graphics.newImage(Props.imagePath)
    Props.grid = spritesheet.NewAnim8Grid(Props.image, playerWidth, playerHeight)

    Props.animations = {}
    Props.animations.walk = Anim8.newAnimation(Props.grid('1-6', 1), 0.1)
    Props.animations.idle = Anim8.newAnimation(Props.grid('1-4', 2), 0.2)
    Props.animations.jump = Anim8.newAnimation(Props.grid('1-2', 3), 0.2, function() resetAnim() end)
    Props.animations.hurt = Anim8.newAnimation(Props.grid('1-2', 4), 0.2, function() resetAnim() end)
    Props.animations.ded = Anim8.newAnimation(Props.grid('1-2', 5), 0.2, 'pauseAtEnd')
    Props.currentAnim8 = Props.animations.walk

    Props.goal = goal
    Props.goalx = goalx
    Props.goaly = goaly

    Face(RIGHT)

    if GameMap.layers[PLAYER_START] then
        for _, obj in pairs(GameMap.layers[PLAYER_START].objects) do
            Props.x = obj.x
            Props.y = obj.y
            Props.collider:setX(obj.x)
            Props.collider:setY(obj.y)
            print('start at ', Props.x, Props.y)
            return
        end
    end
end
