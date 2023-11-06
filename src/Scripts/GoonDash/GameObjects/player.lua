local Player = {}
local gameObject = require("Core.gameobject")
local controller = require("Input.controller")
local playerController = require("Input.playerController")
local rectagle = require("Core.rectangle")



function Player.New(data)
    local player = setmetatable({}, Player)
    player.gameobject = gameObject.New()
    player.gameobject.Update = Player.Update
    player.gameobject.GetLocation = Player.GetLocation
    player.gameobject.Draw = Player.Draw
    player.name = data.name
    player.x = data.x
    -- Currently theres an offset in tiled on the player spawn?
    player.y = data.y - data.height
    player.width = data.width
    player.height = data.height
    player.rectangle = rectagle.New(data.x, player.y, data.width, data.height)
    player.playerController = playerController.New()
    -- Have to use closures to pass in self
    player.playerController.controller:BindFunction(controller.Buttons.Left, controller.ButtonStates.DownOrHeld,
        function() player:MoveLeft() end)
    player.playerController.controller:BindFunction(controller.Buttons.Right, controller.ButtonStates.DownOrHeld,
        function() player:MoveRight() end)
    player.playerController.controller:BindFunction(controller.Buttons.Up, controller.ButtonStates.DownOrHeld,
        function() player:MoveUp() end)
    player.playerController.controller:BindFunction(controller.Buttons.Down, controller.ButtonStates.DownOrHeld,
        function() player:MoveDown() end)
    player.gameobject.Game.Game.mainCamera:AttachToGameObject(player)
    return player
end

-- function Player:KeepPlayerInLevelBounds()
    -- local currentLevel = self.gameobject.Game.Game.currentLevel
    -- local currentXnWidth = self.x + self.width
    -- local localcurrentLevelX = currentLevel.sizeX
    -- if self.x + self.width > currentLevel.sizeX then
    --     self.x = currentLevel.sizeX - self.width
    -- end
-- end

function Player:MoveRight()
    self.rectangle.x = self.rectangle.x + 5

end

function Player:MoveLeft()
    self.rectangle.x = self.rectangle.x - 5

end
function Player:MoveUp()
    self.rectangle.y = self.rectangle.y - 5

end

function Player:MoveDown()
    self.rectangle.y = self.rectangle.y + 5

end

function Player:GetLocation()
    return { x = self.rectangle.x, y = self.rectangle.y }
end

function Player:Update()
    -- self:KeepPlayerInLevelBounds()
end
function Player:Draw()
    -- local screenPos = self.rectangle:SdlRect()
    -- local cam = self.gameobject.Game.Game.mainCamera
    -- screenPos.x = screenPos.x - cam.rectangle.x
    -- screenPos.y = screenPos.y - cam.rectangle.y
    -- self.gameobject.Debug.DrawRect(screenPos)
    local drawRect = self.gameobject.Game.Game.mainCamera:GetCameraOffset(self.rectangle)
    self.gameobject.Debug.DrawRect(drawRect:SdlRect())
end

Player.__index = Player
return Player
