local WinBox = {}
local gameObject = require("Core.gameobject")
local rectagle = require("Core.rectangle")
local physics = require("Core.physics")

function WinBox.New(data)
    local winbox = setmetatable({}, WinBox)
    winbox.gameobject = gameObject.New()
    winbox.startLoc = rectagle.New(data.x, data.y, data.width, data.height)
    winbox.rigidbody = physics.AddBody(winbox.startLoc:SdlRect(), winbox, 4)
    physics.ToggleBodyGravity(winbox.rigidbody, false)
    return winbox
end

WinBox.__index = WinBox
return WinBox
