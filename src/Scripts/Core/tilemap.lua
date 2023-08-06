local TileMap = {
    tileAtlases = nil
}
local surface = require("Core.surface")
local ctileset = require("Core.tileset")
local Rectangle = require("Core.rectangle")

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

function TileMap.LoadTilemap(filename)
    local loadedFile = require(filename)
    local xNumTiles = loadedFile.width
    local yNumTiles = loadedFile.height
    local xTileSize = loadedFile.tilewidth
    local yTileSize = loadedFile.tileheight
    local levelSizeX = xNumTiles * xTileSize
    local levelSizeY = yNumTiles * yTileSize

    local loadedSurfaces = {}
    local tilesets = {}
    -- Create a table of all the tilesets so that we can look up tiles in them.
    for i, tileset in ipairs(loadedFile.tilesets) do
        local localTileset = require(tileset.name)
        local set = ctileset:New(tileset.firstgid, localTileset)
        table.insert(tilesets, set)
    end
    table.sort(tilesets, sortByGid)


    -- Load all the surfaces and get their userdata so that we can use them when creating the atlas
    for _, tileset in ipairs(tilesets) do
        local filenames = tileset:GetAllFileNames()
        for _, value in ipairs(filenames) do
            local surfaceUserdata = surface.NewFromFile(value)
            if surfaceUserdata then
                loadedSurfaces[value] = surfaceUserdata
            end
        end
    end


    -- Create atlas 0 for now
    local layer0Atlas = surface.LoadTextureAtlas(levelSizeX, levelSizeY)
    -- Loop through data, and blit to it based on tilemaps
    local x, y = 0, 0
    for layerDepth, layer in ipairs(loadedFile.layers) do
        if layerDepth == 1 then
            for _, gid in ipairs(layer.data) do
                if gid ~= 0 then
                    local tileTileset = checkIfTileInTilesetList(gid, tilesets)
                    local tilePngName, width, height = nil, nil, nil
                    if tileTileset then
                        tilePngName, width, height = tileTileset:GetTile(gid)
                    end
                    local tileX = x * xTileSize
                    local tileY = y * yTileSize
                    if tileTileset.imageTileset then
                        -- If this is an image, we need to raise it since they draw at bottom for some reason
                        tileY = tileY - height + yTileSize
                    end
                    print("Drawing on " .. tileX .. " : " .. tileY)
                    local dstRect = Rectangle:New(tileX, tileY, width, height)
                    local srcRect = Rectangle:New(0, 0, width, height)
                    local userdata = loadedSurfaces[tilePngName]
                    BlitAtlasSurface(layer0Atlas, userdata, dstRect, srcRect)
                end
                if x < xNumTiles - 1 then
                    x = x + 1
                else
                    x = 0
                    y = y + 1
                end
                print("X is " .. x .. " Y is " .. y)
            end
        end
        local texture = surface.CreateTexture(layer0Atlas)
        -- Putting global here for now.
        -- local atlas = {}
        -- table.insert(atlas, texture)
        return texture
    end
end

function TileMap.DrawAtlas(atlas)
    surface.DrawAtlas(atlas)
end

TileMap.__index = TileMap
return TileMap
