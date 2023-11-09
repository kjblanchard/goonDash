---Loads and plays sounds
--- levels: 1:debug 2:info 3:warn 4:error

local Physics = {}
local physics = require("GoonPhysics")
local debug = require("Core.debug")

function Physics.AddBody(bodyRect)
    local bodyNum = physics.AddBody(bodyRect)
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

function Physics.AddForceToBody(bodyNum, xForce, yForce)
    physics.AddBodyForce(bodyNum, xForce, yForce)
end

function Physics.BodyOnGround(bodyNum)
    return physics.BodyOnGround(bodyNum)
end

Physics.__index = Physics
return Physics
