-- require('mobdebug').start()
Lua = {}
local tilemap = require("Tiled.tilemap")
local currentLevel

function Lua.Initialize()
    local gameSettings = require("settings")
    local renderer = require("Graphics.renderer")
    renderer.InitializeWindow(gameSettings.windowName, gameSettings.windowWidth, gameSettings.windowHeight)
end

function Lua.Start()
    currentLevel = tilemap.New("level1")
end

function Lua.Update()
end

function Lua.Draw()
    currentLevel:DrawBackground()
end
