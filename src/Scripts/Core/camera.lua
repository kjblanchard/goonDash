local Camera = {}
local rectangle = require("Core.rectangle")

function Camera.New(screenSizePoint, mapSizePoint)
    local camera = setmetatable({}, Camera)
    camera.rectangle = rectangle.New(0,0, screenSizePoint.x, screenSizePoint.y)
    camera.mapBounds = {}
    camera.mapBounds.x = mapSizePoint.x + 1
    camera.mapBounds.y = mapSizePoint.y
    camera.followTarget = nil
    return camera
end

function Camera:GetRect()
    local dst = self.rectangle:SdlRect()
    return self.rectangle:SdlRectInt()
end

function Camera:Update()
    if not self.followTarget then return end
    local followTargetLoc = self.followTarget:GetLocation()
    if not followTargetLoc then return end

    local diff = followTargetLoc.x - self.rectangle.x
    local middleScreenX = self.rectangle.width / 2
    local maxX = self.mapBounds.x - self.rectangle.width

    if self.rectangle.x < maxX and diff >= middleScreenX then
        local offset = diff - middleScreenX
        self.rectangle.x = self.rectangle.x + offset
    end
    if self.rectangle.x > 0 and diff < middleScreenX then
        local offset = middleScreenX - diff
        self.rectangle.x = self.rectangle.x - offset
    end
    if self.rectangle.x < 0 then self.rectangle.x = 0 end;
    if self.rectangle.x + self.rectangle.width > self.mapBounds.x then self.rectangle.x = self.mapBounds.x - self.rectangle.width end
end


function Camera:GetCameraOffset(rect)
    return rectangle.New(rect.x - self.rectangle.x, rect.y - self.rectangle.y, rect.width, rect.height)
end

function Camera:AttachToGameObject(gameobject)
    self.followTarget = gameobject
end

function Camera:SetCameraToMapBounds(levelSizeX, levelSizeY)
    self.mapBounds.x = levelSizeX
    self.mapBounds.y = levelSizeY
end

Camera.__index = Camera
return Camera
