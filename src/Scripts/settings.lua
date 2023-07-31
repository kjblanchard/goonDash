require('window')
local level1 = require("level1")
local LuaSurface = require("surface")
local TileSet = require("tileset")
local Rectangle = require("rectangle")
-- require('mobdebug').start()

local function sortByGid(a, b)
    return a.firstGid < b.firstGid
end

local function checkIfTileInTilesetList(id, tilesetList)
    for i, tileset in ipairs(tilesetList) do
        if id >= tileset.firstGid and (tilesetList[i + 1] == nil or id < tilesetList[i + 1].firstGid) then
            return tileset
        end
    end
    print("Could not find a tileset containing this tile, something probably is wrong.")
    return nil
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
local levelSizeX = xNumTiles * xTileSize
local levelSizeY = yNumTiles * yTileSize

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


-- Create atlas 0
local layer0Atlas = LuaSurface.LoadTextureAtlas(levelSizeX, levelSizeY)
-- Loop through data, and blit to it based on tilemaps
for _, layer in ipairs(level1.layers) do
    if layer.type == "objectgroup" then
        for _, object in ipairs(layer.objects) do
            -- Need to get the tileset and src rect based on the gid
            local objId = object.gid
            local tileTileset = checkIfTileInTilesetList(objId, tilesets)
            local tilePngName = nil
            if tileTileset then
                tilePngName = tileTileset:GetTile(objId)
            end
            local dstRect = Rectangle:New(object.x, object.y, object.width, object.height)
            print("I should load from file " .. tilePngName .. " at location " .. tostring(dstRect))
            local srcRect = Rectangle:New(0, 0, object.width, object.height)
            local userdata = loadedSurfaces[tilePngName]
            BlitAtlasSurface(layer0Atlas, userdata, dstRect, srcRect)

            -- Need to Blit to the layer 0 atlas here.
        end
    elseif layer.type == "tilelayer" then
        -- local tileData = layer.data
        -- for i, tilegid in ipairs(tileData) do

        -- end
        -- local objId =
    end
end
-- destroy surface and create texture from it

-- Create atlas 1
-- Create atlas 2
-- Create atlas 3
-- Create Solid
-- Create Objects
-- Create atlas 6
-- Create atlas 7
