-- require('mobdebug').start()
Lua = {}
local tilemap = require("Tiled.tilemap")
local debug = require("Core.debug")
local currentLevel

function Lua.Initialize()
    local gameSettings = require("settings")
    local renderer = require("Graphics.renderer")
    renderer.InitializeWindow(gameSettings.windowName, gameSettings.windowWidth, gameSettings.windowHeight)
    debug.Warn("Hello from debug messages!")
end

function Lua.Start()
    currentLevel = tilemap.New("level1")
end

function Lua.Update()
end

function Lua.Draw()
    currentLevel:DrawBackground()
end
