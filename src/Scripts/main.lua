-- require('mobdebug').start()
Lua = {}
local tilemap = require("Core.tilemap")
local loadedTilemap

function Lua.Initialize()
    local renderer = require("Core.renderer")
    local settings = require("settings")
    renderer.InitializeWindow(settings.windowName, settings.windowWidth, settings.windowHeight)
end

function Lua.Start()
    -- print("Hello from Lua Start!")
    loadedTilemap = tilemap.LoadTilemap("level1")


end

function Lua.Update()
    -- print("Hello from Lua Update!")
end

function Lua.Draw()
    -- print("Hello from Lua Draw!")
    loadedTilemap:Draw()

end
