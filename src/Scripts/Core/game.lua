local Game = {}
local camera = require("Core.camera")


Game.Game = nil
Game.Settings = require("settings")

function Game.New()
    local game = setmetatable({}, Game)
    game.mainCamera = camera.New({x = game.Settings.windowWidth, y = game.Settings.windowHeight}, {x = game.Settings.windowWidth, y = game.Settings.windowHeight})
    game.currentLevel = nil
    -- Set game to this
    Game.Game = game
    return game
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