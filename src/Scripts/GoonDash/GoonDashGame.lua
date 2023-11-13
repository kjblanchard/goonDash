local map = require("Core.gameobjectMap")
local player = require("GoonDash.GameObjects.player")
local enemy = require("GoonDash.GameObjects.enemy")

-- You should set the translation map here to load gameobjects from the tiled map
map.TranslationMap["Player"] = player.New
map.TranslationMap["Enemy"] = enemy.New
