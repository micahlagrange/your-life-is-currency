DEBUG            = false
Colors           = {}
Colors.WHITE     = function() return 1, 1, 1 end
Colors.DebugText = function() return 1, 1, 0 end

function DebugPlayerColor(lastCollided)
    if lastCollided == nil then
        return 1, 1, 1
    end
    if lastCollided == 'platform' then
        return 1, 0, 0
    end
    if lastCollided == 'ground' then
        return 1, 1, 0
    end
end

Colliders               = {}
Colliders.PLAYER        = 'Player'
Colliders.GROUND        = 'Ground'
Colliders.BULLETS       = 'Bullets'
Colliders.ENEMY         = 'Enemy'
Colliders.GOAL          = 'Goal'
Colliders.PLATFORMS     = 'Platforms'
Colliders.MOUSE_POINTER = 'MousePointer'
Colliders.CONSUMABLE    = 'Consumable'
Colliders.GHOST         = 'Ghost'
Colliders.UI_ELEMENT    = 'UiElement'
