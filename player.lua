module('player', package.seeall)

-- Initialize player variables
Props = {
    x = love.graphics.getWidth() / 2,
    y = love.graphics.getHeight() / 2,
    -- Vertical velocity (initially zero)
    yVelocity = 0,
    -- Flag to check if the player is on the ground
    onGround = true,
    image = love.graphics.newImage('sprites/inevitable-brew.icon.png'),
    scaleX = 1,
    scaleY = 1,
    width = 1,
    height = 1,
    facing = LEFT,
    collider = nil
}

-- Set player jump strength (adjust as needed)
local playerSpeed = 500
local jumpStrength = 650
-- Apply gravity (adjust gravity as needed)
local gravity = 1600

function Draw()
    love.graphics.draw(
        Props.image,
        Props.x,
        Props.y - Props.height,
        0,
        Props.scaleX,
        Props.scaleY)
end

function Move(dt)
    -- Initialize movement deltas
    local dx = 0

    -- Check keyboard input
    if love.keyboard.isDown('right') then
        dx = 1
        Props.facing = RIGHT
    elseif love.keyboard.isDown('left') then
        dx = -1
        Props.facing = LEFT
    end

    -- Update player position based on deltas
    Props.x = Props.x + dx * playerSpeed * dt
end

function Jump(dt)
    -- Handle player jumping
    if love.keyboard.isDown('space') and Props.onGround then
        Props.yVelocity = -jumpStrength
        Props.onGround = false
    end

    Props.yVelocity = Props.yVelocity + gravity * dt

    -- Update player position
    Props.y = Props.y + Props.yVelocity * dt

    -- Check if player is back on the ground
    if Props.y >= love.graphics.getHeight() / 2 then
        Props.y = love.graphics.getHeight() / 2
        Props.yVelocity = 0
        Props.onGround = true
    end
end

function InitPlayer(scaleX, scaleY, rectCollider)
    Props.scaleX = scaleX
    Props.scaleY = scaleY
    Props.width = Props.image:getWidth() * scaleX
    Props.height = Props.image:getHeight() * scaleY
    Props.collider = rectCollider
end
