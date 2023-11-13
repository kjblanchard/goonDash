local Player = {}
local gameObject = require("Core.gameobject")
local controller = require("Input.controller")
local playerController = require("Input.playerController")
local rectagle = require("Core.rectangle")
local physics = require("Core.physics")
local sound = require("Core.sound")

local MAX_JUMP_FRAMES = 15

sound.LoadSfx("jump")
sound.LoadSfx("death")



function Player.New(data)
    local player = setmetatable({}, Player)
    player.name = data.name
    player.gameobject = gameObject.New()
    player.gameobject.Update = Player.Update
    player.gameobject.GetLocation = Player.GetLocation
    player.gameobject.Draw = Player.Draw
    player.gameobject.Restart = Player.Restart
    player.playerController = playerController.New()
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
        function() player:RestartMap() end)
    player.playerController.controller:BindFunction(controller.Buttons.Confirm, controller.ButtonStates.DownOrHeld,
        function() player:JumpExtend() end)
    player.playerController.controller:BindFunction(controller.Buttons.Confirm, controller.ButtonStates.Up,
        function() player:JumpEnd() end)
    player.gameobject.Game.Game.mainCamera:AttachToGameObject(player)

    player.startLoc = rectagle.New(data.x, data.y, data.width, data.height)
    player.rigidbody = physics.AddBody(player.startLoc:SdlRect(), player)

    -- Setup Player for initial scene
    Player.Restart(player)

    -- Return the instantiated player
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
    if self.isDead then return end
    self.jumping = true
    self.jumpFrames = 1
    physics.AddForceToBody(self.rigidbody, 0, -120)
    sound.PlaySfx("jump")
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

function Player:RestartMap()
    if not self.isDead then return end
    self.gameobject.Game.Game:Restart()
end

function Player:Update()
    if self.isDead then return end
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
        -- Prevent multiple overlaps from happening in lua
        -- if not self.thisFrameOverlaps[enemiesOverlapped[i].body] then
        self.thisFrameOverlaps[enemiesOverlapped[i].body] = enemiesOverlapped[i].direction
        -- end
    end
    -- Check to see if we are just overlapping with the enemy
    for overlapBodyNum, overlapBodyDirection in pairs(self.thisFrameOverlaps) do
        local enemy = physics.GetGameObjectFromBodyNum(overlapBodyNum)
        if enemy.isDead or self.lastFrameOverlaps[overlapBodyNum] then
        else
            -- local overlapDirection = physics.GetOverlapDirection(self.rigidbody, overlapBodyNum)
            print("Overlap direction is " .. overlapBodyDirection)

            if overlapBodyDirection == 3 then
                -- if enemyY >= self.rectangle.y - self.rectangle.height  then
                physics.SetBodyVelocity(self.rigidbody, nil, 0)
                local enemy = physics.GetGameObjectFromBodyNum(overlapBodyNum)
                enemy.isDead = true
                self:Jump()
            else
                self.isDead = true
                sound.PlaySfx("death")
            end
        end
    end
end

function Player:Restart()
    self.rectangle = rectagle.New(self.startLoc.x, self.startLoc.y, self.startLoc.width, self.startLoc.height)
    physics.SetBodyCoordinates(self.rigidbody, self.rectangle.x, self.rectangle.y)
    physics.SetBodyVelocity(self.rigidbody, 0, 0)
    self.lastFrameOnGround = false
    self.onGround = false
    self.jumping = false
    self.jumpFrames = 0
    self.lastFrameOverlaps = {}
    self.thisFrameOverlaps = {}
    self.isDead = false
end

function Player:Draw()
    if self.isDead then return end
    local drawRect = self.gameobject.Game.Game.mainCamera:GetCameraOffset(self.rectangle)
    self.gameobject.Debug.DrawRect(drawRect:SdlRectInt())
end

Player.__index = Player
return Player
