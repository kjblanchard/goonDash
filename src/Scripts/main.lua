-- require('mobdebug').start()
Lua = {}
local tilemap = require("Tiled.tilemap")
local debug = require("Core.debug")
local currentLevel
local sound = require("Core.sound")
local gameObjectMap = require("GoonDash.GameObjects.gameobjectMap")
local kb = require("Core.keyboardMap")

function Lua.Initialize()
    local gameSettings = require("settings")
    local renderer = require("Graphics.renderer")
    renderer.InitializeWindow(gameSettings.windowName, gameSettings.windowWidth, gameSettings.windowHeight)
end

function Lua.Start()
    currentLevel = tilemap.New("level1")
    local entities = currentLevel.entityLayer
    local entityObjects = entities["objects"]
    for _, object in ipairs(entityObjects) do
        gameObjectMap.CreateInstance(object)
    end
    sound.Load("test", 20.397, 43.08)
    sound.Play("test")
end

function Lua.InputEvent(buttonPressed, keyDown)
    local boundKeyPressed = kb.SdlToBoundButtons(buttonPressed)
    if boundKeyPressed == nil then return end
    local keydownText = keyDown and "down" or "up"
    debug.Info("Button pressed is " .. boundKeyPressed .. " and the key is " .. keydownText)
end

function Lua.Update()
    gameObjectMap.Update()
end

function Lua.Draw()
    currentLevel:DrawBackground()
end
