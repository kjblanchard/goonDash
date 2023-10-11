local Game = {}
local camera = require("Core.camera")

Game.Game = nil

function Game.New()
    local game = setmetatable({}, Game)
    game.mainCamera = camera.New({x = 512, y = 288}, {x = 1000, y = 288})
    -- Set game to this
    Game.Game = game
    return game
end

function Game:UpdateCamera()
    self.mainCamera:Update()
end

Game.__index = Game
return Game