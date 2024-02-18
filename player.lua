local player {}

-- Initialize player variables
local player = {
    x = love.graphics.getWidth() / 2,
    y = love.graphics.getHeight() / 2,
    yVelocity = 0,  -- Vertical velocity (initially zero)
    onGround = true  -- Flag to check if the player is on the ground
}
local playerImage
-- Set player jump strength (adjust as needed)
local playerSpeed = 500
local jumpStrength = 650
-- Apply gravity (adjust gravity as needed)
local gravity = 1600

function player.move(dt)
    local dx, dy = 0, 0  -- Initialize movement deltas

    -- Check keyboard input
    if love.keyboard.isDown('right') then
        dx = 1
    elseif love.keyboard.isDown('left') then
        dx = -1
    end

    -- Update player position based on deltas
    player.x = player.x + dx * playerSpeed * dt
end

function player.jump(dt)
    -- Handle player jumping
    if love.keyboard.isDown('space') and player.onGround then
        player.yVelocity = -jumpStrength
        player.onGround = false
    end

    player.yVelocity = player.yVelocity + gravity * dt

    -- Update player position
    player.y = player.y + player.yVelocity * dt

    -- Check if player is back on the ground
    if player.y >= love.graphics.getHeight() / 2 then
        player.y = love.graphics.getHeight() / 2
        player.yVelocity = 0
        player.onGround = true
    end
end
