local Physics = {}
local physics = require("GoonPhysics")

function Physics.CreateBody(message)
    -- Body/shape return
    return  physics.CreateBody()

end

function Physics.GetBodyPosition(body)
    -- x/y
    return physics.GetBodyPosition(body)

end

function Physics.AddForce(body, x, y)
    physics.ApplyForce(body, x, y)
end

Physics.__index = Physics
return Physics
