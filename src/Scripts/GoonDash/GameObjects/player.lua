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
        function() player:TryJump() end)
    player.playerController.controller:BindFunction(controller.Buttons.Confirm, controller.ButtonStates.DownOrHeld,
        function() player:JumpExtend() end)
    player.playerController.controller:BindFunction(controller.Buttons.Confirm, controller.ButtonStates.Up,
        function() player:JumpEnd() end)
    player.gameobject.Game.Game.mainCamera:AttachToGameObject(player)
    -- Physics
    player.rigidbody = physics.AddBody(player.rectangle:SdlRect(), player)
    player.lastFrameOnGround = false
    player.onGround = false
    player.jumping = false
    player.jumpFrames = 0

    player.lastFrameOverlaps = {}
    player.thisFrameOverlaps = {}

    player.isDead = false
    return player
end

function Player:MoveRight()
    if self.isDead then return end
    physics.AddForceToBody(self.rigidbody, 10, 0)
end

function Player:MoveLeft()
    if self.isDead then return end
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

function Player:TryJump()
    if not self.onGround or self.jumping or self.isDead then return end
    self:Jump()
end

function Player:Jump()
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

    -- Try shallow copy
    self.lastFrameOverlaps = self.thisFrameOverlaps
    self.lastFrameOverlaps = {}
    for key, value in pairs(self.thisFrameOverlaps) do
        self.lastFrameOverlaps[key] = value
    end
    -- Try move
    -- table.move(self.thisFrameOverlaps, 1, #self.thisFrameOverlaps, 1,  self.lastFrameOverlaps)
    self.thisFrameOverlaps = {}

    -- Handle overlap table to see if we are just overlapping
    local enemiesOverlapped = physics.GetOverlappingBodiesByType(self.rigidbody, 2)
    for i = 1, #enemiesOverlapped do
        self.thisFrameOverlaps[enemiesOverlapped[i].body] = true
    end
    -- Check to see if we are just overlapping with the enemy
    for overlapBodyNum, _ in pairs(self.thisFrameOverlaps) do
        local enemy = physics.GetGameObjectFromBodyNum(overlapBodyNum)
        if enemy.isDead or self.lastFrameOverlaps[overlapBodyNum] then
        else
            -- local overlapDirection = physics.GetOverlapDirection(self.rigidbody, overlapBodyNum)
            local overlapDirection = enemiesOverlapped[overlapBodyNum].direction
            if overlapDirection == 3 then
                -- if enemyY >= self.rectangle.y - self.rectangle.height  then
                physics.SetBodyVelocity(self.rigidbody, nil, 0)
                local enemy = physics.GetGameObjectFromBodyNum(overlapBodyNum)
                enemy.isDead = true
                self:Jump()
            else
                self.isDead = true
            end
        end
    end
end

function Player:Draw()
    if self.isDead then return end
    local drawRect = self.gameobject.Game.Game.mainCamera:GetCameraOffset(self.rectangle)
    -- self.gameobject.Debug.DrawRect(drawRect:SdlRect())
    self.gameobject.Debug.DrawRect(drawRect:SdlRectInt())
end

Player.__index = Player
return Player
