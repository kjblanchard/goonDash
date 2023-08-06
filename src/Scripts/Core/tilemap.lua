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


    -- Create atlas 0
    local layer0Atlas = surface.LoadTextureAtlas(levelSizeX, levelSizeY)
    -- Loop through data, and blit to it based on tilemaps
    for _, layer in ipairs(loadedFile.layers) do
        if layer.type == "objectgroup" then
            for _, object in ipairs(layer.objects) do
                -- Need to get the tileset and src rect based on the gid
                local objId = object.gid
                local tileTileset = checkIfTileInTilesetList(objId, tilesets)
                local tilePngName = nil
                if tileTileset then
                    tilePngName = tileTileset:GetTile(objId)
                end
                local dstRect = Rectangle:New(object.x, object.y - 64, object.width, object.height)
                -- print("I should load from file " .. tilePngName .. " at location " .. tostring(dstRect))
                local srcRect = Rectangle:New(0, 0, object.width, object.height)
                local userdata = loadedSurfaces[tilePngName]
                BlitAtlasSurface(layer0Atlas, userdata, dstRect, srcRect)
            end
        elseif layer.type == "tilelayer" then
            -- local tileData = layer.data
            -- for i, tilegid in ipairs(tileData) do

            -- end
            -- local objId =
        end
    end
    local texture = surface.CreateTexture(layer0Atlas)
    -- Putting global here for now.
    -- local atlas = {}
    -- table.insert(atlas, texture)
    return texture
end

function TileMap.DrawAtlas(atlas)
    surface.DrawAtlas(atlas)
end

TileMap.__index = TileMap
return TileMap
