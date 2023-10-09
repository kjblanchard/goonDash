---A gameobject that has all of the functions that are required, and some functions that should be overridden
local GameObject = {}
GameObject.Debug = require("Core.debug")
GameObject.Sound = require("Core.sound")
GameObject.CurrentId = 0

function GameObject.New()
    local gameobject = setmetatable({}, GameObject)
    GameObject.CurrentId = GameObject.CurrentId + 1
    gameobject.id = GameObject.CurrentId
    return gameobject
end

function GameObject:Update()
end

function GameObject:Draw()
end

GameObject.__index = GameObject
return GameObject
