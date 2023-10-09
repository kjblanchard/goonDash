local Player = {}
local gameObject = require("Core.gameobject")



function Player.New(data)
    local player = setmetatable({}, Player)
    player.gameobject = gameObject.New()
    player.gameobject.Update = Player.Update
    player.name = data.name
    player.x = data.x
    player.y = data.y
    player.width = data.width
    player.height = data.height
    return player
end

function Player:Update()
    gameObject.Debug.Debug("Player Update")
end

Player.__index = Player
return Player
