module('pickable', package.seeall)

INVENTORY = {}

OBJECT_LAYER_PICKABLES = 'Pickables'

local pickups = {}

local cleanDelay = 20
local cleanTimer = cleanDelay
local theWastelandOfDeadGarbage = -9999

local the3DPyramidThingImage = love.graphics.newImage('sprites/cash.png')

local function findIndexForPickableID(name)
    --return 0 if none found
    for idx, p in ipairs(pickups) do
        if p.pkguid == name then
            return idx
        end
    end
    return 0
end

local function deletePickable(pickup, name)
    local idx = findIndexForPickableID(name)
    if idx > 0 then table.remove(pickups, idx) end

    pickup.x = theWastelandOfDeadGarbage
    pickup.y = theWastelandOfDeadGarbage
    pcall(function()
        pickup.collider:setCollisionClass('Ghost')
        pickup.collider:setX(theWastelandOfDeadGarbage)
        pickup.collider:setY(theWastelandOfDeadGarbage)
    end)
end

local function cleanUpPickables(dt)
    cleanTimer = cleanTimer - dt
    if cleanTimer > 0 then return end

    local colliders = World:queryCircleArea(theWastelandOfDeadGarbage, theWastelandOfDeadGarbage, 300)
    for _, collider in ipairs(colliders) do
        print('delete pickup collider ', collider)
        print(pcall(function() collider:destroy() end))
    end
    cleanTimer = cleanDelay
end

function Draw()
    for _, pickup in ipairs(pickups) do
        love.graphics.draw(
            the3DPyramidThingImage,
            pickup.collider:getX(),
            pickup.collider:getY(),
            0)
    end
end

function Update(dt)
    cleanUpPickables(dt)
end

function Pickup(collider)
    local pickup = collider:getObject()
    print('pickup ', pickup.pkguid)
    table.insert(INVENTORY, pickup)
    deletePickable(pickup, pickup.pkguid)
    SFX.ItemGet:play()
    player.Props.gil = player.Props.gil + 1
end

function GeneratePickables()
    local counter = 0
    local function getUniqueID()
        counter = counter + 1
        return counter
    end

    if GameMap.layers[OBJECT_LAYER_PICKABLES] then
        for _, obj in pairs(GameMap.layers[OBJECT_LAYER_PICKABLES].objects) do
            local pickup = {}
            pickup.pkguid = getUniqueID()
            print('  -- generate pickup ', pickup.pkguid)
            pickup.collider = World:newRectangleCollider(
                obj.x - 32,
                obj.y - 32,
                32,
                32)
            pickup.collider:setType('static')
            pickup.collider:setCollisionClass('Pickable')
            pickup.collider:setObject(pickup)
            pickup.collider:setGravityScale(0)
            table.insert(pickups, pickup)
        end
    end
end
