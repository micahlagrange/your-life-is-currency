local object     = require('libs.classic')
local money      = require('src.pickables.money')
local inspect    = require('libs.inspect')

local INVENTORY  = {}

local pickups    = {}
local Pickable   = {}
local pickable   = object:extend()

local cleanDelay = 20
local cleanTimer = cleanDelay

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

    pickup.x = NO_MANS_LAND
    pickup.y = NO_MANS_LAND
    pcall(function()
        pickup.collider:setCollisionClass(Colliders.GHOST)
        pickup.collider:setX(NO_MANS_LAND)
        pickup.collider:setY(NO_MANS_LAND)
    end)
end

local function cleanUpPickables(dt)
    cleanTimer = cleanTimer - dt
    if cleanTimer > 0 then return end

    local colliders = World:queryCircleArea(NO_MANS_LAND, NO_MANS_LAND, 300)
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


function pickable:update(dt)
    self.instance.x = self.x
    self.instance.y = self.y
    self.instance:update(dt)
    cleanUpPickables(dt)
end

function pickable:draw()
    if self.picked then return end
    self.instance:draw()
end

function Pickable.Pickup(collider)
    local pickup = collider:getObject()
    print('pickup ', pickup.pkguid)
    table.insert(INVENTORY, pickup)
    Pickable.deletePickable(pickup, pickup.pkguid)
    SFX.ItemGet:play()
    return pickup.instance
end

function pickable:new(entity)
    self.picked = false
    self.pkguid = getUniqueID()
    print('  -- generate pickup ', self.pkguid)
    self.x = entity.x
    self.y = entity.y
    self.collider = World:newRectangleCollider(
        entity.x,
        entity.y,
        32,
        32)
    self.collider:setType('static')
    self.collider:setCollisionClass(Colliders.CONSUMABLE)
    self.collider:setObject(self)
    self.collider:setGravityScale(0)

    assert(entity.id ~= nil, "Entity id nil: " .. inspect(entity))
    if entity.id == Items.MONEY then
        self.instance = money(entity)
    end
end

function Pickable.New(entity)
    local p = pickable(entity)
    table.insert(pickups, p)
    return p
end

return Pickable
