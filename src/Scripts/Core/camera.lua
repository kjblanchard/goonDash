local Camera = {}
local rectangle = require("Core.rectangle")

function Camera.New(screenSizePoint, mapSizePoint)
    local camera = setmetatable({}, Camera)
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

    -- Check to see if the follow target is halfway past the screen, if so move
    -- var diff = _target.Location.X - _camera.Location.X;
    -- var middle_screen_x = _camera.GetWorldSize().X / 2;
    -- //Try moving Right if needed if the camera has room
    -- var noRoom = _camera.LevelWidth - _camera.GetWorldSize().X;
    -- if (_camera.Location.X < noRoom)
    -- {
    --     if (diff >= middle_screen_x)
    --     {
    --         var offset = diff - middle_screen_x;
    --         _camera.Location.X += offset;
    --     }
    -- }

    -- //Try moving left if needed if the camera has room
    -- if (_camera.Location.X > 0)
    -- {
    --     if (diff < middle_screen_x)
    --     {
    --         var offset = middle_screen_x - diff;
    --         _camera.Location.X -= offset;
    --     }
    -- }
    local diff = newLocation.x - self.rectangle.x
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

    -- if newLocation.x < 0 then newLocation.x = 0 end
    -- if newLocation.x > maxX then newLocation.x = maxX end
    -- self.rectangle.x = newLocation.x
    -- local realLoc = self.followTarget:GetLocation()
    -- print("Cam loc: " .. self.rectangle.x .. " Y: " .. self.rectangle.y .. " Follow loc" .. realLoc.x .. " Y: " .. realLoc.y)
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
