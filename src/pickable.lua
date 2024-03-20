local object = require('libs.classic')

local INVENTORY = {}

local pickups = {}
local Pickable = {}
local pickable = object:extend()

local cleanDelay = 20
local cleanTimer = cleanDelay
local theWastelandOfDeadGarbage = -9999

local the3DPyramidThingImage = love.graphics.newImage('sprites/cash.png')

function Pickable.findIndexForPickableID(name)
    --return 0 if none found
    for idx, p in ipairs(pickups) do
        if p.pkguid == name then
            return idx
        end
    end
    return 0
end

function Pickable.deletePickable(pickup, name)
    pickup.picked = true
    local idx = Pickable.findIndexForPickableID(name)
    if idx > 0 then table.remove(pickups, idx) end

    pickup.x = theWastelandOfDeadGarbage
    pickup.y = theWastelandOfDeadGarbage
    pcall(function()
        pickup.collider:setCollisionClass(Colliders.GHOST)
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

local idcounter = 0
local function getUniqueID()
    idcounter = idcounter + 1
    return idcounter
end

function pickable:draw()
    if self.picked then return end
    love.graphics.draw(
        the3DPyramidThingImage,
        self.collider:getX() - 16,
        self.collider:getY() - 16,
        0)
end

function pickable:update(dt)
    cleanUpPickables(dt)
end

function Pickable.Pickup(collider)
    local pickup = collider:getObject()
    print('pickup ', pickup.pkguid)
    table.insert(INVENTORY, pickup)
    Pickable.deletePickable(pickup, pickup.pkguid)
    SFX.ItemGet:play()
    return 1
end

function pickable:new(entity)
    self.picked = false
    self.pkguid = getUniqueID()
    self.x, self.y = entity.x, entity.y
    print('  -- generate pickup ', self.pkguid)
    self.collider = World:newRectangleCollider(
        self.x,
        self.y,
        32,
        32)
    self.collider:setType('static')
    self.collider:setCollisionClass(Colliders.CONSUMABLE)
    self.collider:setObject(self)
    self.collider:setGravityScale(0)
end

function Pickable.New(entity)
    local p = pickable(entity)
    table.insert(pickups, p)
    return p
end

return Pickable
