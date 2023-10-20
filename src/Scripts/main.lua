-- Uncomment this if you need to debug with zerobrane
-- require('mobdebug').start()
Lua = {}
local controller = require("Input.controller")
local game = require("Core.game")
local gameInstance = nil

---Initialize Lua components
function Lua.Initialize()
    local gameSettings = require("settings")
    local renderer = require("Graphics.renderer")
    gameInstance = game.New()
    renderer.InitializeWindow(gameSettings.windowName, gameSettings.windowWidth, gameSettings.windowHeight)
end

---Run the games start function
function Lua.Start()
    gameInstance:Start()
end

---Handles a Input event from sdl by passing it into the controller
function Lua.InputEvent(buttonPressed, keyDown)
    controller.OnInput(buttonPressed, keyDown)
end

---Updates the game
function Lua.Update()
    gameInstance:Update()
end

---Draws the game
function Lua.Draw()
    gameInstance:Draw()
end
