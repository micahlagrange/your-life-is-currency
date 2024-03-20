DEBUG            = true
Colors           = {}
Colors.WHITE     = function() return 1, 1, 1 end
Colors.RED       = function() return 1, 0, 0 end
Colors.DebugText = function() return 1, 1, 0 end
Colors.GREEN     = function() return 0, 1, 0 end

function DebugPlayerColor(onGround)
    if not onGround then
        return 1, 1, 1
    end
    return 1, 0, 0
end

Colliders                  = {}
Colliders.PLAYER           = 'Player'
Colliders.GROUND           = 'Ground'
Colliders.BULLETS          = 'Bullets'
Colliders.ENEMY            = 'Enemy'
Colliders.GOAL             = 'Goal'
Colliders.PLATFORMS        = 'Platforms'
Colliders.MOUSE_POINTER    = 'MousePointer'
Colliders.CONSUMABLE       = 'Consumable'
Colliders.GHOST            = 'Ghost'
Colliders.UI_ELEMENT       = 'UiElement'

EVENTS                     = {}
EVENTS.Timer               = {}
EVENTS.Timer.TIMER_EXPIRED = 'TIMER_EXPIRED'

EntityProps                = {}
EntityProps.PICKABLE       = 'Pickable'
EntityProps.VALUE          = 'Value'
EntityProps.GOAL           = 'Goal'

Items                      = {}
Items.MONEY                = 'Money'
Items.EXIT                 = 'Exit'
