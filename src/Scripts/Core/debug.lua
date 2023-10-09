---Sends messages to the C logger.
--- levels: 1:debug 2:info 3:warn 4:error

local Dbg = {}
local goonDebug = require("GoonDebug")
---Sends a Debug message to the C logger
---@param message string message to send out
function Dbg.Debug(message)
    goonDebug.Message(message, 1)
end

---Sends a Info message to the C logger
---@param message string message to send out
function Dbg.Info(message)
    goonDebug.Message(message, 2)
end

---Sends a warning to the C logger
---@param message string message to send out
function Dbg.Warn(message)
    goonDebug.Message(message, 3)
end

---Sends a error message to the C logger
---@param message string message to send out
function Dbg.Error(message)
    goonDebug.Message(message, 4)
end

Dbg.__index = Dbg
return Dbg
