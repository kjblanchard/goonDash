local Game = {}
local camera = require("Core.camera")
local gameObjectMap = require("Core.gameobjectMap")
local currentLevel
local sound = require("Core.sound")
local tilemap = require("Tiled.tilemap")
local controller = require("Input.controller")



Game.Game = nil
Game.Settings = require("settings")

function Game.New()
    local game = setmetatable({}, Game)
    game.mainCamera = camera.New({ x = game.Settings.windowWidth, y = game.Settings.windowHeight },
        { x = game.Settings.windowWidth, y = game.Settings.windowHeight })
    game.currentLevel = nil
    -- Set game to this
    Game.Game = game
    require(Game.Settings.game .. "/" .. Game.Settings.game .. "Game")
    return game
end

function Game:Start()
    -- Should load the level and such from game.
    currentLevel = tilemap.New(Game.Settings.initialTilemap)
    self:SetLevel(currentLevel)
    local entities = currentLevel.entityLayer
    local entityObjects = entities["objects"]
    for _, object in ipairs(entityObjects) do
        gameObjectMap.CreateInstance(object)
    end
    -- Load this from the tilemap
    if currentLevel.bgm and currentLevel.bgm.bgmName ~= "" then
        sound.Load(currentLevel.bgm.bgmName, currentLevel.bgm.loopBegin, currentLevel.bgm.loopEnd)
        sound.Play(currentLevel.bgm.bgmName)
    end

end

function Game:Update()
    gameObjectMap.Update()
    controller.UpdateControllers()
    self:UpdateCamera()
end

function Game:Draw()
    currentLevel:DrawBackground(self.mainCamera)
    gameObjectMap.Draw()

end

function Game:UpdateCamera()
    self.mainCamera:Update()
end

function Game:SetLevel(level)
    self.currentLevel = level
    self.mainCamera:SetCameraToMapBounds(level.sizeX, level.sizeY)
end

Game.__index = Game
return Game
