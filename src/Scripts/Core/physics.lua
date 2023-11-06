---Loads and plays sounds
--- levels: 1:debug 2:info 3:warn 4:error

local Physics = {}
local physics = require("GoonPhysics")
local debug = require("Core.debug")

function Physics.AddBody(bodyRect)
    local bodyNum = physics.AddBody(bodyRect)
    return bodyNum
end

function Physics.GetBodyCoordinates(bodyNum)
    local x, y = physics.GetBodyLocation(bodyNum)
    return x, y
end

Physics.__index = Physics
return Physics
