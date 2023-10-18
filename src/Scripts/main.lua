-- require('mobdebug').start()
Lua = {}
local tilemap = require("Tiled.tilemap")
-- local debug = require("Core.debug")
local currentLevel
local sound = require("Core.sound")
local gameObjectMap = require("GoonDash.GameObjects.gameobjectMap")
local controller = require("Input.controller")
local game = require("Core.game")
local gameInstance = nil

function Lua.Initialize()
    local gameSettings = require("settings")
    local renderer = require("Graphics.renderer")
    gameInstance = game.New()
    renderer.InitializeWindow(gameSettings.windowName, gameSettings.windowWidth, gameSettings.windowHeight)
end

function Lua.Start()
    -- Should load the level and such from game.
    currentLevel = tilemap.New("level1")
    gameInstance:SetLevel(currentLevel)
    local entities = currentLevel.entityLayer
    local entityObjects = entities["objects"]
    for _, object in ipairs(entityObjects) do
        gameObjectMap.CreateInstance(object)
    end
    -- Load this from the tilemap
    if currentLevel.bgm and currentLevel.bgm.bgmName ~= "" then
        print("start " .. currentLevel.bgm.loopBegin .. " end " .. currentLevel.bgm.loopEnd)
        sound.Load(currentLevel.bgm.bgmName, currentLevel.bgm.loopBegin, currentLevel.bgm.loopEnd)
        sound.Play(currentLevel.bgm.bgmName)
    end
end

function Lua.InputEvent(buttonPressed, keyDown)
    controller.OnInput(buttonPressed, keyDown)
end

function Lua.Update()
    gameObjectMap.Update()
    controller.UpdateControllers()
    gameInstance:UpdateCamera()
end

function Lua.Draw()
    currentLevel:DrawBackground(gameInstance.mainCamera)
end
