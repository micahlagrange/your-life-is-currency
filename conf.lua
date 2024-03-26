FIRST_LEVEL = 'Level_2'

DEBUG = true

function love.conf(t)
    t.title = "Drakeshot"
    t.version = "11.4" -- It's a lie, we actually use 11.5 but itch.io throws a dumb error!
    t.console = true
    t.window.width = 1280
    t.window.height = 960
    t.window.vsync = 0
end
