-- require('mobdebug').start()
Lua = {}
local tilemap = require("Tiled.tilemap")
-- local debug = require("Core.debug")
local currentLevel
local sound = require("Core.sound")
local gameObjectMap = require("GoonDash.GameObjects.gameobjectMap")
local controller = require("Input.controller")
local pc = require("Input.playerController")

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
    pc_instance = pc.New()
    sound.Load("test", 20.397, 43.08)
    sound.Play("test")
end

function Lua.InputEvent(buttonPressed, keyDown)
    controller.OnInput(buttonPressed, keyDown)
end

function Lua.Update()
    gameObjectMap.Update()
    controller.UpdateControllers()
end

function Lua.Draw()
    currentLevel:DrawBackground()
end
