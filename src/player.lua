local spritesheet = require('spritesheet')
local pickable = require('src.pickable')
local timer = require('src.system.timer')
local inventory = require('src.pickables.inventory')

-- Initialize player variables
player = {
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
    inventory = inventory(),
    dead = false,
    canAccelJump = true,
    jumpTimerExpired = false
}

-- Set player jump strength (adjust as needed)
PLAYER_SPEED = 6000
JUMP_STRENGTH = 1900
MAX_SPEED = 500
FORCE_JUMP_ACCELLERATION = 12000
FORCE_JUMP_MAX_SPEED = 500
FORCE_JUMP_START_SPEED = 300

WIN_CONDITION = 3

local debugCircle = {}
local debugCollisionText = ""

local function isFalling(collider)
    local _, vy = collider:getLinearVelocity()
    return vy > 0
end

local function playerBelowPlatform(playercollider, platformcollider)
    local _, py = playercollider:getPosition()
    local _, ty = platformcollider:getPosition()
    local th = TILE_SIZE
    return py > ty - th
end


local function feetTouchGround(playercollider, groundcollider)
    -- is the player passing through a one-way platform or above it
    return not playerBelowPlatform(playercollider, groundcollider)
end

local function preSolve(playerc, collidedc, contact)
    local nx, ny = contact:getNormal()
    debugCollisionText = ny
    if not playerc.collision_class == Colliders.PLAYER then return end
    if collidedc.collision_class == Colliders.GROUND then
        if ny ~= 0 and feetTouchGround(playerc, collidedc) and not isFalling(playerc) then
            player.onGround = true
            player.canAccelJump = true
        end
    elseif collidedc.collision_class == Colliders.PLATFORMS then
        if playerBelowPlatform(playerc, collidedc) then
            contact:setEnabled(false)
        else
            if not isFalling(player.collider) then
                player.onGround = true
                player.canAccelJump = true
            end
        end
    end
end

function player.Draw()
    local px, py = player.collider:getPosition()
    local scaleX
    if player.facing == RIGHT then
        scaleX = player.scaleX
    else
        -- players origin is their left side, so when the image
        -- flips we need to push them right
        player.x = player.x + player.width
        scaleX = -player.scaleX
    end

    if DEBUG then love.graphics.setColor(DebugPlayerColor(player.onGround)) end
    player.currentAnim8:draw(
        player.image,
        player.x - player.width / 2,
        player.y - player.height / 2,
        0,
        scaleX,
        player.scaleY)

    if DEBUG then
        local vx, vy = player.collider:getLinearVelocity()
        love.graphics.setColor(Colors.DebugText())
        love.graphics.print(px .. "\n" .. py .. "\n", px - 40, py - 40)
        love.graphics.setColor(Colors.RED())
        love.graphics.print("yVel:" .. vy .. "\n" .. "xVel:" .. vx .. "\n", px - 40, py + 40)
        if not player.onGround then
            love.graphics.setColor(Colors.GREEN())
        else
            love.graphics.setColor(Colors.RED())
        end
        local onGroundText = "inAir:" .. (player.onGround and 'false' or 'true')
        local jumpKeyPressed = "jumpKey:" .. (love.keyboard.isDown('space') and 'true' or 'false')
        local jumpExpired = "jumpExpired:" .. (player.jumpTimerExpired and 'true' or 'false')
        local debugCollisionText = "collision normal:" .. debugCollisionText
        love.graphics.print(jumpKeyPressed .. "  " .. onGroundText .. "  " .. jumpExpired .. "\n" .. debugCollisionText,
            px + 32,
            py)
        love.graphics.setColor(Colors.RED())
        if debugCircle[1] ~= nil then
            love.graphics.circle('fill', debugCircle[1], debugCircle[2], 3)
        end
    end
end

function Face(direction)
    player.facing = direction
    if direction == LEFT then
        player.currentSprite = 1
    else
        player.currentSprite = 2
    end
end

local function resetAnim()
    player.currentAnim8 = player.animations.idle
end

local function chooseConstantAnimation(velocity)
    if player.currentAnim8 ~= player.animations.walk
        and player.currentAnim8 ~= player.animations.idle then
        return
    end
    if velocity == 0 then
        player.currentAnim8 = player.animations.idle
    else
        player.currentAnim8 = player.animations.walk
    end
end

local function hurt()
    local ec = player.collider:getEnterCollisionData('Enemy')
    local hurt = false
    hurt = ec.collider:getObject():attak(player)
    if hurt == false then return end

    if player.currentAnim8 == player.animations.hurt then return end
    print('oof')
    player.currentAnim8 = player.animations.hurt
    player.hp = player.hp - 1
    if player.hp <= 0 then
        player.dead = true
        player.currentAnim8 = player.animations.ded
    end
end

local function checkInAir()
    if player.collider:exit(Colliders.GROUND)
        or player.collider:exit(Colliders.PLATFORMS) then
        return true
    end
end

function player.UpdatePlayer(dt)
    local px = player.collider:getLinearVelocity()


    if checkInAir() then
        player.onGround = false
    end

    -- anim
    chooseConstantAnimation(px)
    player.currentAnim8:update(dt)

    if player.dead or player.win then return end

    -- damage
    if player.collider:enter(Colliders.ENEMY) then
        hurt()
    end

    -- Check keyboard input
    if (love.keyboard.isDown('d') or love.keyboard.isDown('right')) and px < MAX_SPEED then
        player.collider:applyForce(PLAYER_SPEED, 0)
        Face(RIGHT)
    elseif (love.keyboard.isDown('a') or love.keyboard.isDown('left')) and px > -MAX_SPEED then
        player.collider:applyForce(-PLAYER_SPEED, 0)
        Face(LEFT)
    end

    -- Update player position based on collider
    player.x, player.y = player.collider:getX(), player.collider:getY()

    if player.collider:enter(Colliders.CONSUMABLE) then
        local collided = player.collider:getEnterCollisionData(Colliders.CONSUMABLE)
        local pickup = collided.collider
        player.inventory:add(pickable.Pickup(pickup))
    end

    -- if player.jumpTimerExpired then player.jumpTimerExpired = false end
end

local function expireJumpTimer()
    player.jumpTimerExpired = true
end

function player.Jump()
    local vx, vy = player.collider:getLinearVelocity()

    if love.keyboard.isDown('space') and vy >= -FORCE_JUMP_MAX_SPEED and player.canAccelJump and not player.jumpStarted and player.onGround then
        -- start jump
        player.jumpStarted = true
        -- if traversing a wall or flying into a ceiling bc of this dumb algo, expire after a half sec or somethin
        timer.add('JumpTimer', .5, expireJumpTimer, false)
        player.collider:setLinearVelocity(vx, -FORCE_JUMP_START_SPEED)
    else
        -- at top jump speed or jump key released or timer expired
        if player.jumpStarted then
            if not love.keyboard.isDown('space') or vy <= -FORCE_JUMP_MAX_SPEED or player.jumpTimerExpired then
                print('arc')
                player.jumpStarted = false
                player.canAccelJump = false
            end
        end
        if player.jumpStarted and player.canAccelJump and vy >= -FORCE_JUMP_MAX_SPEED then
            -- keep accellerating jump until max
            print('accel')
            player.collider:applyForce(0, -FORCE_JUMP_ACCELLERATION)
        end
        if player.jumpTimerExpired then
            player.jumpTimerExpired = false
        end
    end
end

function player.LinearJump()
    if player.onGround then
        player.onGround = false
        local vx, vy = player.collider:getLinearVelocity()
        player.collider:setLinearVelocity(vx, 0)
        player.collider:applyLinearImpulse(0, -JUMP_STRENGTH)
    end
end

function player.InitPlayer(scaleX, scaleY, goal, startX, startY)
    local playerWidth = 32  -- actual number of pixels wide for each sprite in the sprite sheet
    local playerHeight = 32 -- actual number of pixels high for each sprite in the sprite sheet

    player.scaleX = scaleX
    player.scaleY = scaleY
    player.width = playerWidth * scaleX
    player.height = playerWidth * scaleY

    player.collider = World:newBSGRectangleCollider(
        player.x,
        player.y,
        player.width / 1.34,
        player.height,
        6
    )
    player.collider:setCollisionClass(Colliders.PLAYER)
    player.collider:setFixedRotation(true)
    player.collider:setPreSolve(preSolve)
    player.collider:setObject(player)
    player.image = love.graphics.newImage(player.imagePath)
    player.grid = spritesheet.NewAnim8Grid(player.image, playerWidth, playerHeight)

    player.animations = {}
    player.animations.walk = Anim8.newAnimation(player.grid('1-6', 1), 0.1)
    player.animations.idle = Anim8.newAnimation(player.grid('1-4', 2), 0.2)
    player.animations.jump = Anim8.newAnimation(player.grid('1-2', 3), 0.2, function() resetAnim() end)
    player.animations.hurt = Anim8.newAnimation(player.grid('1-2', 4), 0.2, function() resetAnim() end)
    player.animations.ded = Anim8.newAnimation(player.grid('1-2', 5), 0.2, 'pauseAtEnd')
    player.currentAnim8 = player.animations.walk

    player.goal = goal

    Face(RIGHT)

    player.x = startX
    player.y = startY
    player.collider:setX(player.x)
    player.collider:setY(player.y)
    player.initialized = true
    print('start at ', player.x, player.y)
end

return player
