local DeathBox = {}
local gameObject = require("Core.gameobject")
local rectagle = require("Core.rectangle")
local physics = require("Core.physics")

function DeathBox.New(data)
    local deathbox = setmetatable({}, DeathBox)
    deathbox.gameobject = gameObject.New()
    deathbox.gameobject.Draw = DeathBox.Draw
    deathbox.startLoc = rectagle.New(data.x, data.y, data.width, data.height)
    deathbox.rigidbody = physics.AddBody(deathbox.startLoc:SdlRect(), deathbox, 3)
    physics.ToggleBodyGravity(deathbox.rigidbody, false)
    return deathbox
end

function DeathBox:Draw()
    local drawRect = self.gameobject.Game.Game.mainCamera:GetCameraOffset(self.startLoc)
    self.gameobject.Debug.DrawRect(drawRect:SdlRectInt())
end

DeathBox.__index = DeathBox
return DeathBox
