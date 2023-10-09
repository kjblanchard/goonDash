local GameObjectMap = {}
local debug = require("Core.debug")
local player = require("GoonDash.GameObjects.player")

GameObjectMap.TranslationMap = {
    Player = player.New
}

GameObjectMap.GameObjects = {}

function GameObjectMap.CreateInstance(data)
    if #data.type == 0 then
        debug.Warn("This object doesn't have a type, will not instantiate anything, name is  " .. data.name)
        return nil
    end
    local spawnFunc = GameObjectMap.TranslationMap[data.type]
    if spawnFunc == nil then
        debug.Warn("Trying to instantiate something that isn't in the translation map " .. data.type)
        return nil
    end
    local instance = spawnFunc(data)
    if instance == nil then
        debug.Warn("Instance of object is nil, something probably happened when trying to instantiate type " .. data.type)
        return nil
    end
    table.insert(GameObjectMap.GameObjects, instance)
end

function GameObjectMap.Update()
    for _, value in ipairs(GameObjectMap.GameObjects) do
        value.gameobject.Update()
        -- if value.Update then value:Update() end
    end
end

GameObjectMap.__index = GameObjectMap
return GameObjectMap
