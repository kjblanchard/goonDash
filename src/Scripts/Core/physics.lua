---Global physics functions that interact with the C physics library
local Physics = {}
local physics = require("GoonPhysics")

Physics.BodyToGameObject = {}

function Physics.GetGameObjectFromBodyNum(bodyNum)
    return Physics.BodyToGameObject[bodyNum]
end

---Adds a rigidbody to the C api scene
---@param bodyRect table A rectangle representing the bodys bounding box
---@param object table The object that this rigidbody belongs to
---@param bodyType  integer?  Number representing the body type.  0 is Static, 1 is default, anything else is user defined
---@return unknown
function Physics.AddBody(bodyRect, object,  bodyType)
    bodyType = bodyType or 1
    local bodyNum = physics.AddBody(bodyRect, bodyType)
    Physics.BodyToGameObject[bodyNum] = object
    for key, value in pairs(Physics.BodyToGameObject) do
        print("Body num is " .. key .. " and body table is " .. tostring(value) )

    end
    return bodyNum
end

function Physics.AddStaticBody(bodyRect)
    local bodyNum = physics.AddStaticBody(bodyRect)
    return bodyNum
end

function Physics.GetBodyCoordinates(bodyNum)
    local x, y = physics.GetBodyLocation(bodyNum)
    return x, y
end

function Physics.GetOverlapDirection(bodyNum, overlapBodyNumb)
    return physics.GetOverlapDirection(bodyNum, overlapBodyNumb)
end

function Physics.AddForceToBody(bodyNum, xForce, yForce)
    physics.AddBodyForce(bodyNum, xForce, yForce)
end

function Physics.BodyOnGround(bodyNum)
    return physics.BodyOnGround(bodyNum)
end

function Physics.GetOverlappingBodiesByType(bodyNum, bodyType)
    return physics.GetOverlappingBodies(bodyNum, bodyType)
end

function Physics.SetBodyVelocity(bodyNum, velX, velY)
    if velX == nil or velY == nil then
        local cVelX, CVelY = physics.GetBodyVelocity(bodyNum)
        velX = velX or cVelX
        velY = velY or CVelY
    end
    return physics.SetBodyVelocity(bodyNum, velX, velY)
end

Physics.__index = Physics
return Physics
