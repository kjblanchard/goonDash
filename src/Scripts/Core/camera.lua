local Camera = {}
local rectangle = require("Core.rectangle")

function Camera.New(screenSizePoint, mapSizePoint)
    local camera = setmetatable({}, Camera)
    -- camera.rectangle = rectangle.New(0, 0, 512, 288)
    camera.rectangle = rectangle.New(0,0, screenSizePoint.x, screenSizePoint.y)
    camera.mapBounds = {}
    camera.mapBounds.x = mapSizePoint.x
    camera.mapBounds.y = mapSizePoint.y
    camera.followTarget = nil
    return camera
end

function Camera:GetRect()
    local dst = self.rectangle:SdlRect()
    return self.rectangle.SdlRect(self.rectangle)
end

function Camera:Update()
    if not self.followTarget then return end
    local newLocation = self.followTarget:GetLocation()
    if not newLocation then return end
    if newLocation.x < 0 then newLocation.x = 0 end
    local maxX = self.mapBounds.x - self.rectangle.width
    if newLocation.x > maxX then newLocation.x = maxX end
    -- newLocation.x = math.max(0, newLocation.x)
    -- newLocation.x = math.min(self.mapBounds.x - self.rectangle.width, newLocation.x )
    -- Set y
    self.rectangle.x = newLocation.x
end

function Camera:AttachToGameObject(gameobject)
    self.followTarget = gameobject
end

Camera.__index = Camera
return Camera
