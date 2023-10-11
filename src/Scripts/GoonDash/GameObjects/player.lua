local Player = {}
local gameObject = require("Core.gameobject")
local controller = require("Input.controller")
local playerController = require("Input.playerController")



function Player.New(data)
    local player = setmetatable({}, Player)
    player.gameobject = gameObject.New()
    player.gameobject.Update = Player.Update
    player.gameobject.GetLocation = Player.GetLocation
    player.name = data.name
    player.x = data.x
    player.y = data.y
    player.width = data.width
    player.height = data.height
    player.playerController = playerController.New()
    -- Have to use closures to pass in self
    player.playerController.controller:BindFunction(controller.Buttons.Left, controller.ButtonStates.Held, function () player:MoveLeft() end)
    player.playerController.controller:BindFunction(controller.Buttons.Right, controller.ButtonStates.Held, function () player:MoveRight() end)
    player.gameobject.Game.Game.mainCamera:AttachToGameObject(player)
    return player
end


function Player:MoveRight()
    self.x = self.x + 5

end

function Player:MoveLeft()
    self.x = self.x - 5

end

function Player:GetLocation()
    return {x = self.x, y = self.y}
end

function Player:Update()
    gameObject.Debug.Debug("Player Update")
end

Player.__index = Player
return Player
