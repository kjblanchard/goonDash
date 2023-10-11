---A gameobject that has all of the functions that are required, and some functions that should be overridden
local GameObject = {}
GameObject.Debug = require("Core.debug")
GameObject.Sound = require("Core.sound")
GameObject.Game = require("Core.game")
GameObject.CurrentId = 0

---Create a new gameobject
---@return table GameObject new gameobject instance, mainly just an id.
function GameObject.New()
    local gameobject = setmetatable({}, GameObject)
    GameObject.CurrentId = GameObject.CurrentId + 1
    gameobject.id = GameObject.CurrentId
    return gameobject
end

function GameObject:GetLocation()
end

---Gameobjects update function
function GameObject:Update()
end

---Gameobjects Draw function
function GameObject:Draw()
end

---Attach a controller to this gameobject.
---comment
---@param controller table the controller that will be used
function GameObject:AttachController(controller)
end

GameObject.__index = GameObject
return GameObject
