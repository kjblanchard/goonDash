local Camera = {}
local rectangle = require("Core.rectangle")

function Camera.New()
    local camera = setmetatable({}, Camera)
    camera.rectangle = rectangle.New(0, 0, 512, 288)
    return camera
end

function Camera:GetRect()
    local dst = self.rectangle:SdlRect()
    return self.rectangle.SdlRect(self.rectangle)
end

Camera.__index = Camera
return Camera
