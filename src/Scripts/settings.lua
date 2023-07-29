-- local main = require("main")
local stubs = require("stubs")
local level1 = require("level_1")
local function createFilepath(path)
    return './assets/' .. path .. '.png'
end

-- Create Tileset struct
local TileSet = {}
function TileSet:New(name, firstGid, filename, udata)
    local obj = { name = name, firstGid = firstGid, filename = filename, userdata = udata }
    setmetatable(obj, self)
    self.__index = self
    return obj
end
Settings = {
    windowName = "Goon Dash",
    windowWidth = 648,
    windowHeight = 480
}
InitializeWindow(Settings.windowName, Settings.windowWidth, Settings.windowHeight)

local xNumTiles = level1.width
local yNumTiles = level1.height
local xTileSize = level1.tilewidth
local yTileSize = level1.tileheight

local tilesets = {}
for _, tileset in ipairs(level1.tilesets) do
    local udata = LuaSurface.NewFromFile(tileset.name)
    local set = TileSet:New(tileset.name, tileset.firstgid, tileset.filename, udata)
    table.insert(tilesets, set)
end

-- Load these tilesets into surfaces from C so that we can reference them,
-- as we will need these surfaces when making tilesets.

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
