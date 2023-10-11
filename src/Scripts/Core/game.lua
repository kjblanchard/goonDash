local Game = {}
local camera = require("Core.camera")

function Game.New()
    local game = setmetatable({}, Game)
    game.mainCamera = camera.New()
    return game
end

Game.__index = Game
return Game