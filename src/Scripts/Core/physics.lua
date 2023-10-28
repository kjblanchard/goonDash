local Physics = {}
local physics = require("GoonPhysics")
local dbg = require("Core.debug")

function Physics.CreateBody(message)
    -- Body/shape return
    return  physics.CreateBody()

end

function Physics.GetBodyPosition(body)
    -- x/y
    return physics.GetBodyPosition(body)
end

function Physics.CreateSolidObjects(solidObjectsTable)
    local solidObjects = {}
    for _, solidObjectData in ipairs(solidObjectsTable) do
        dbg.Debug("Creating solid object: " .. solidObjectData.name .. " with vert count " .. #solidObjectData.polygon)
        physics.CreateGroundObject(solidObjectData, #solidObjectData.polygon)
    end

end

function Physics.AddForce(body, x, y)
    physics.ApplyForce(body, x, y)
end

Physics.__index = Physics
return Physics
