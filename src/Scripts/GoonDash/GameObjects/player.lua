local Player = {}
local gameObject = require("Core.gameobject")
local controller = require("Input.controller")
local playerController = require("Input.playerController")
local rectagle = require("Core.rectangle")
local physics = require("Core.physics")

local MAX_JUMP_FRAMES = 15



function Player.New(data)
    local player = setmetatable({}, Player)
    player.gameobject = gameObject.New()
    player.gameobject.Update = Player.Update
    player.gameobject.GetLocation = Player.GetLocation
    player.gameobject.Draw = Player.Draw
    player.name = data.name
    player.x = data.x
    -- Currently theres an offset in tiled on the player spawn, this was due to tiled tsx tiles and their position.
    -- player.y = data.y - data.height
    player.width = data.width
    player.height = data.height
    player.rectangle = rectagle.New(data.x, player.y, data.width, data.height)
    print("Player rectangle is " .. tostring(player.rectangle))
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
    player.playerController.controller:BindFunction(controller.Buttons.Confirm, controller.ButtonStates.DownOrHeld,
        function() player:Jump() end)
    player.playerController.controller:BindFunction(controller.Buttons.Confirm, controller.ButtonStates.DownOrHeld,
        function() player:JumpExtend() end)
    player.playerController.controller:BindFunction(controller.Buttons.Confirm, controller.ButtonStates.Up,
        function() player:JumpEnd() end)
    player.gameobject.Game.Game.mainCamera:AttachToGameObject(player)
    -- Physics
    player.rigidbody = physics.AddBody(player.rectangle:SdlRect())
    player.lastFrameOnGround = false
    player.onGround = false
    player.jumping = false
    player.jumpFrames = 0
    return player
end

function Player:MoveRight()
    physics.AddForceToBody(self.rigidbody, 10, 0)
end

function Player:MoveLeft()
    physics.AddForceToBody(self.rigidbody, -10, 0)
end

function Player:MoveUp()
    -- physics.AddForceToBody(self.rigidbody, 0, -10)
end

function Player:MoveDown()
    -- physics.AddForceToBody(self.rigidbody, 0, 10)
end

function Player:GetLocation()
    return { x = self.rectangle.x, y = self.rectangle.y }
end

function Player:Jump()
    if not self.onGround or self.jumping then return end
    self.jumping = true
    self.jumpFrames = 1
    physics.AddForceToBody(self.rigidbody, 0, -120)
end

function Player:JumpEnd() self.jumping = false end

function Player:JumpExtend()
    if not self.jumping then return end
    if self.jumpFrames < MAX_JUMP_FRAMES then
        physics.AddForceToBody(self.rigidbody, 0, -10)
        self.jumpFrames = self.jumpFrames + 1
    else
        self.jumping = false
    end

end

function Player:Update()
    self.onGround = physics.BodyOnGround(self.rigidbody)
    if self.onGround and not self.lastFrameOnGround then
        self.jumping = false
    end
    self.lastFrameOnGround = self.onGround
    -- if not self.onGround and physics.BodyOnGround(self.rigidbody) then
    --     self.onGround = true
    --     self.jumping = false
    -- end
    local x, y = physics.GetBodyCoordinates(self.rigidbody)
    if x == nil then return end
    self.rectangle.x = x
    self.rectangle.y = y
end

function Player:Draw()
    local drawRect = self.gameobject.Game.Game.mainCamera:GetCameraOffset(self.rectangle)
    -- self.gameobject.Debug.DrawRect(drawRect:SdlRect())
    self.gameobject.Debug.DrawRect(drawRect:SdlRectInt())
end

Player.__index = Player
return Player
