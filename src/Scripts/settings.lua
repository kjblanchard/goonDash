require('window')
local level1 = require("level1")
local LuaSurface = require("surface")
local TileSet = require("tileset")

local function sortByGid(a, b)
    return a.firstGid < b.firstGid
end

-- Settings = {
--     windowName = "Goon Dash",
--     windowWidth = 648,
--     windowHeight = 480
-- }
-- InitializeWindow(Settings.windowName, Settings.windowWidth, Settings.windowHeight)

local xNumTiles = level1.width
local yNumTiles = level1.height
local xTileSize = level1.tilewidth
local yTileSize = level1.tileheight

local loadedSurfaces = {}
local tilesets = {}

-- Create a table of all the tilesets so that we can look up tiles in them.
for i, tileset in ipairs(level1.tilesets) do
    local localTileset = require(tileset.name)
    local set = TileSet:New(tileset.firstgid, localTileset)
    table.insert(tilesets, set)
end
table.sort(tilesets, sortByGid)

-- Load all the surfaces and get their userdata so that we can use them when creating the atlas
for _, tileset in ipairs(tilesets) do
    local filenames = tileset:GetAllFileNames()
    for _, value in ipairs(filenames) do
        local surfaceUserdata = LuaSurface.NewFromFile(value)
        if surfaceUserdata then
            loadedSurfaces[value] = surfaceUserdata
        end
    end
end

for key, value in pairs(loadedSurfaces) do
    print("Key is " .. key, " and the value is " .. tostring(value))
end

-- Create atlas 0
-- Create a atlas surface in C
-- Loop through data, and blit to it based on tilemaps
-- destroy surface and create texture from it

-- Create atlas 1
-- Create atlas 2
-- Create atlas 3
-- Create Solid
-- Create Objects
-- Create atlas 6
-- Create atlas 7
