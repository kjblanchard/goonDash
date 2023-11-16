local Player = {}
local gameObject = require("Core.gameobject")
local controller = require("Input.controller")
local playerController = require("Input.playerController")
local rectagle = require("Core.rectangle")
local physics = require("Core.physics")
local sound = require("Core.sound")

local MAX_JUMP_LENGTH_SECONDS = 0.45
local leftRightBaseSpeed = 1000
local initialJumpSpeed = -110
local extendJumpSpeed = -250

sound.LoadSfx("jump")
sound.LoadSfx("death")
sound.LoadSfx("win")



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
    player.playerController.controller:BindFunction(controller.Buttons.Confirm, controller.ButtonStates.Down,
        function() player:TryJump() end)
    player.playerController.controller:BindFunction(controller.Buttons.Confirm, controller.ButtonStates.Down,
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
    if self.isDead or self.win then return end
    local forceX = leftRightBaseSpeed
    print("Deltatime is " .. Lua.DeltaTime,
        " Force is " .. leftRightBaseSpeed .. " and the amount to add to force is " .. forceX)
    physics.AddForceToBody(self.rigidbody, forceX, 0, Lua.DeltaTime)
end

function Player:MoveLeft()
    if self.isDead or self.win then return end
    local forceX = -leftRightBaseSpeed
    physics.AddForceToBody(self.rigidbody, forceX, 0, Lua.DeltaTime)
end

function Player:GetLocation()
    return { x = self.rectangle.x, y = self.rectangle.y }
end

function Player:TryJump()
    if not self.onGround or self.jumping or self.isDead or self.win then return end
    self:Jump()
end

function Player:Jump()
    -- if self.isDead then return end
    self.jumping = true
    self.jumpFrames = 0
    -- physics.AddForceToBody(self.rigidbody, 0, initialJumpSpeed * Lua.DeltaTime)
    physics.AddImpactToBody(self.rigidbody, 0, initialJumpSpeed)
    sound.PlaySfx("jump")
end

function Player:JumpEnd() self.jumping = false end

function Player:JumpExtend()
    if not self.jumping then return end
    print("Jump time is " .. self.jumpFrames .. " and max time is " .. MAX_JUMP_LENGTH_SECONDS)
    if self.jumpFrames < MAX_JUMP_LENGTH_SECONDS then
        -- physics.AddForceToBody(self.rigidbody, 0, extendJumpSpeed * Lua.DeltaTime, Lua.DeltaTime)
        physics.AddForceToBody(self.rigidbody, 0, extendJumpSpeed, Lua.DeltaTime)
        self.jumpFrames = self.jumpFrames + Lua.DeltaTime
    else
        self.jumping = false
    end

end

function Player:RestartMap()
    -- if not self.isDead or not self.win then return end
    -- if not self.isDead or not self.win then return end
    if self.isDead or self.win then
        self.gameobject.Game.Game:Restart()
    end
end

function Player:Update()
    if self.isDead or self.win then return end
    self.onGround = physics.BodyOnGround(self.rigidbody)
    if self.onGround and not self.lastFrameOnGround then
        self.jumping = false
    end
    self.lastFrameOnGround = self.onGround
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
    -- Overlaps
    self.thisFrameOverlaps = {}
    self:HandleEnemyOverlap()
    self:HandleDeathboxOverlap()
    self:HandleWinboxOverlap()
end

function Player:HandleEnemyOverlap()
    -- Handle overlap table to see if we are just overlapping
    local enemyBodyType = 2
    local enemiesOverlapped = physics.GetOverlappingBodiesByType(self.rigidbody, enemyBodyType)
    if not #enemiesOverlapped then return end
    for i = 1, #enemiesOverlapped do
        self.thisFrameOverlaps[enemiesOverlapped[i].body] = { direction = enemiesOverlapped[i].direction,
            type = enemyBodyType }
    end
    -- Check to see if we are just overlapping with the enemy
    for overlapBodyNum, overlapBodyTable in pairs(self.thisFrameOverlaps) do
        if overlapBodyTable.type == enemyBodyType then
            local enemy = physics.GetGameObjectFromBodyNum(overlapBodyNum)
            if enemy.isDead or self.lastFrameOverlaps[overlapBodyNum] then
            else

                if overlapBodyTable.direction == 3 then
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
end

function Player:HandleDeathboxOverlap()
    -- Handle overlap table to see if we are just overlapping
    local enemyBodyType = 3
    local enemiesOverlapped = physics.GetOverlappingBodiesByType(self.rigidbody, enemyBodyType)
    if not #enemiesOverlapped then return end
    for i = 1, #enemiesOverlapped do
        self.thisFrameOverlaps[enemiesOverlapped[i].body] = { direction = enemiesOverlapped[i].direction,
            type = enemyBodyType }
    end
    -- Check to see if we are just overlapping with the enemy
    for overlapBodyNum, overlapBodyTable in pairs(self.thisFrameOverlaps) do
        if overlapBodyTable.type == enemyBodyType then
            if self.lastFrameOverlaps[overlapBodyNum] then
            else
                self.isDead = true
                sound.PlaySfx("death")
            end
        end
    end
end

function Player:HandleWinboxOverlap()
    -- Handle overlap table to see if we are just overlapping
    local enemyBodyType = 4
    local enemiesOverlapped = physics.GetOverlappingBodiesByType(self.rigidbody, enemyBodyType)
    if not #enemiesOverlapped then return end
    for i = 1, #enemiesOverlapped do
        self.thisFrameOverlaps[enemiesOverlapped[i].body] = { direction = enemiesOverlapped[i].direction,
            type = enemyBodyType }
    end
    -- Check to see if we are just overlapping with the enemy
    for overlapBodyNum, overlapBodyTable in pairs(self.thisFrameOverlaps) do
        if overlapBodyTable.type == enemyBodyType then
            if self.lastFrameOverlaps[overlapBodyNum] then
            else
                self.win = true
                sound.PlaySfx("win")
            end
        end
    end
end

function Player:Restart()
    self.rectangle = rectagle.New(self.startLoc.x, self.startLoc.y, self.startLoc.width, self.startLoc.height)
    physics.SetBodyCoordinates(self.rigidbody, self.rectangle.x, self.rectangle.y)
    physics.SetBodyVelocity(self.rigidbody, 0, 0)
    -- physics.AddForceToBody(self.rigidbody, 100, 0)
    self.lastFrameOnGround = false
    self.onGround = false
    self.jumping = false
    self.jumpFrames = 0
    self.lastFrameOverlaps = {}
    self.thisFrameOverlaps = {}
    self.isDead = false
    self.win = false
end

function Player:Draw()
    if self.isDead then return end
    local drawRect = self.gameobject.Game.Game.mainCamera:GetCameraOffset(self.rectangle)
    self.gameobject.Debug.DrawRect(drawRect:SdlRectInt())
end

Player.__index = Player
return Player
