local GameObjectMap = {}
local debug = require("Core.debug")
---The map of functions per type to instantiate gameobjects
GameObjectMap.TranslationMap = {}
---List of all the gameobjects that are loaded currently
GameObjectMap.GameObjects = {}

---Creates an instance of a gameobject, must be added in the translation map.
---@param data table tiled object that we should build, has type info
function GameObjectMap.CreateInstance(data)
    if #data.type == 0 then
        debug.Warn("This object doesn't have a type, will not instantiate anything, name is  " .. data.name)
        return
    end
    local spawnFunc = GameObjectMap.TranslationMap[data.type]
    if spawnFunc == nil then
        debug.Warn("Trying to instantiate something that isn't in the translation map " .. data.type)
        return
    end
    local instance = spawnFunc(data)
    if instance == nil then
        debug.Warn("Instance of object is nil, something probably happened when trying to instantiate type " .. data.type)
        return
    end
    table.insert(GameObjectMap.GameObjects, instance)
end

---Updates all of the gameobjects currently available
function GameObjectMap.Update()
    for _, value in ipairs(GameObjectMap.GameObjects) do
        -- Call update on the gameobject, but pass in the actual instance, probably don't need to do it this way.
        value.gameobject.Update(value)
    end
end

function GameObjectMap.Restart()
    for _, value in ipairs(GameObjectMap.GameObjects) do
        -- Call update on the gameobject, but pass in the actual instance, probably don't need to do it this way.
        value.gameobject.Restart(value)
    end
end

---Updates all of the gameobjects currently available
function GameObjectMap.Draw()
    for _, value in ipairs(GameObjectMap.GameObjects) do
        -- Call update on the gameobject, but pass in the actual instance, probably don't need to do it this way.
        value.gameobject.Draw(value)
    end
end

GameObjectMap.__index = GameObjectMap
return GameObjectMap
