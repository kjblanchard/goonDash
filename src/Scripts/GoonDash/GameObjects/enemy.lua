local Enemy = {}
local gameObject = require("Core.gameobject")
local rectagle = require("Core.rectangle")
local physics = require("Core.physics")

function Enemy.New(data)
    local enemy = setmetatable({}, Enemy)
    enemy.gameobject = gameObject.New()
    enemy.gameobject.Update = Enemy.Update
    enemy.gameobject.GetLocation = Enemy.GetLocation
    enemy.gameobject.Draw = Enemy.Draw
    enemy.x = data.x
    enemy.width = data.width
    enemy.height = data.height
    enemy.rectangle = rectagle.New(data.x, data.y, data.width, data.height)
    print("Enemy rectangle is " .. tostring(enemy.rectangle))
    -- Physics
    enemy.rigidbody = physics.AddBody(enemy.rectangle:SdlRect(), enemy, 2)
    print("Enemy rigidbody is " .. enemy.rigidbody)
    enemy.isDead = false
    return enemy
end

function Enemy:GetLocation()
    return { x = self.rectangle.x, y = self.rectangle.y }
end


function Enemy:Update()
    local x, y = physics.GetBodyCoordinates(self.rigidbody)
    if x == nil then return end
    self.rectangle.x = x
    self.rectangle.y = y
end

function Enemy:Draw()
    if self.isDead then return end
    local drawRect = self.gameobject.Game.Game.mainCamera:GetCameraOffset(self.rectangle)
    -- self.gameobject.Debug.DrawRect(drawRect:SdlRect())
    self.gameobject.Debug.DrawRect(drawRect:SdlRectInt())
end

Enemy.__index = Enemy
return Enemy
