local Player = {}
local gameObject = require("Core.gameobject")
local controller = require("Input.controller")
local playerController = require("Input.playerController")
local rectagle = require("Core.rectangle")
local physics = require("Core.physics")

local moveSpeed = 50000
local jumpButtonHeldFrames = 0
local jumpButtonMaxHeldFrames = 20
local jumpSoeed = -1000000
local jumpBoost = -70000



function Player.New(data)
    local player = setmetatable({}, Player)
    player.gameobject = gameObject.New()
    player.gameobject.Update = Player.Update
    player.gameobject.GetLocation = Player.GetLocation
    player.gameobject.Draw = Player.Draw
    player.name = data.name
    -- player.x = data.x
    -- player.y = data.y
    player.width = data.width
    player.height = data.height
    player.rectangle = rectagle.New(data.x, data.y, data.width, data.height)
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
    player.playerController.controller:BindFunction(controller.Buttons.Confirm, controller.ButtonStates.Down,
        function() player:Jump() end)
    player.playerController.controller:BindFunction(controller.Buttons.Confirm, controller.ButtonStates.Held,
        function() player:JumpBoost() end)

    player.gameobject.Game.Game.mainCamera:AttachToGameObject(player)
    player.body, player.shape = physics.CreateBody()
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
    physics.AddForce(self.body, moveSpeed, 0)

end

function Player:MoveLeft()
    physics.AddForce(self.body, -moveSpeed, 0)

end

function Player:MoveUp()
end

function Player:MoveDown()
end
function Player:Jump()
    jumpButtonHeldFrames = 0
    physics.AddForce(self.body, 0, jumpSoeed)
end

function Player:JumpBoost()
    if jumpButtonHeldFrames >= jumpButtonMaxHeldFrames then return end
    physics.AddForce(self.body, 0, jumpBoost)
    jumpButtonHeldFrames = jumpButtonHeldFrames + 1
end

function Player:GetLocation()
    return { x = self.rectangle.x, y = self.rectangle.y }
end

function Player:Update()
    local x, y = physics.GetBodyPosition(self.body)
    self.rectangle.x = x
    self.rectangle.y = y
end

function Player:Draw()
    local drawRect = self.gameobject.Game.Game.mainCamera:GetCameraOffset(self.rectangle)
    self.gameobject.Debug.DrawRect(drawRect:SdlRect())
end

Player.__index = Player
return Player
