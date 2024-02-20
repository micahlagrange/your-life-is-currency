module('player', package.seeall)

-- Initialize player variables
Props = {
    x = love.graphics.getWidth() / 2,
    y = love.graphics.getHeight() / 2,
    -- Vertical velocity (initially zero)
    yVelocity = 0,
    -- Flag to check if the player is on the ground
    image = love.graphics.newImage('sprites/inevitable-brew.icon.png'),
    scaleX = 1,
    scaleY = 1,
    width = 1,
    height = 1,
    onGround = false,
    facing = LEFT,
    collider = nil
}

-- Set player jump strength (adjust as needed)
PLAYER_SPEED = 6000
JUMP_STRENGTH = 1500
MAX_SPEED = 400

function Draw()
    love.graphics.draw(
        Props.image,
        Props.x - Props.width / 2,
        Props.y - Props.height / 2,
        0,
        Props.scaleX,
        Props.scaleY)
end

function Move()
    local px = Props.collider:getLinearVelocity()

    -- Check keyboard input
    if love.keyboard.isDown('right') and px < MAX_SPEED then
        Props.collider:applyForce(PLAYER_SPEED, 0)
        Props.facing = RIGHT
    elseif love.keyboard.isDown('left') and px > -MAX_SPEED then
        Props.collider:applyForce(-PLAYER_SPEED, 0)
        Props.facing = LEFT
    end

    -- Update player position based on deltas
    Props.x, Props.y = Props.collider:getX(), Props.collider:getY()
end

function Jump()
    if Props.collider:enter('Platform') then
        local collided = Props.collider:getEnterCollisionData('Platform')
        local platform = collided.collider

        if Props.y + Props.height / 2 < platform:getY() then
            Props.onGround = true
        end
    end
    if love.keyboard.isDown('space') and Props.onGround then
        Props.collider:applyLinearImpulse(0, -JUMP_STRENGTH)
        Props.onGround = false
    end
end

function InitPlayer(scaleX, scaleY)
    Props.scaleX = scaleX
    Props.scaleY = scaleY
    Props.width = Props.image:getWidth() * scaleX
    Props.height = Props.image:getHeight() * scaleY
    Props.collider = World:newBSGRectangleCollider(
        player.Props.x,
        player.Props.y,
        player.Props.width,
        player.Props.height,
        10)
    Props.collider:setCollisionClass('Player')
    Props.collider:setFixedRotation(true)

    -- local function custom_collision(collider_1, collider_2, contact)
    --     print(collider_1.collision_class, collider_2.collision_class)
    --     if collider_1.collision_class == 'Player' and collider_2.collision_class == 'Platform' then
    --         Props.onGround = true
    --     end
    -- end

    -- Props.collider:setPreSolve(custom_collision)
end
