local TileMap = {}
TileMap.tileSets = nil
local Tileset = require("Tiled.tileset")
local Rectangle = require("Core.rectangle")
local TileAtlas = require("Graphics.textureAtlas")
local Surface = require("Graphics.surface")

---Used to sort It's tilemaps so that they are ordered by GID
---@param a any
---@param b any
---@return boolean
local function sortByGid(a, b)
    return a.firstGid < b.firstGid
end

---Checks to see if a tile is inside of a tileset.
---@param id number The tile id to checkfor
---@param tilesetList table list of tilesets
---@return table|nil The tileset that contains the tile, otherwise nil
local function checkIfTileInTilesetList(id, tilesetList)
    for i, tileset in ipairs(tilesetList) do
        if id >= tileset.firstGid and (tilesetList[i + 1] == nil or id < tilesetList[i + 1].firstGid) then
            return tileset
        end
    end
    print("Could not find a tileset containing this tile, something probably is wrong.")
    return nil
end

function TileMap:Draw()
    for index, value in ipairs(self.tileSets) do
        -- print(value)
        value:DrawAtlas()
    end
end

function TileMap.New(filename)
    local tilemap = {}
    setmetatable(tilemap, TileMap)
    tilemap.__index = TileMap
    tilemap.tileSets = {}
    local loadedFile = require(filename)
    local xNumTiles = loadedFile.width
    local yNumTiles = loadedFile.height
    local xTileSize = loadedFile.tilewidth
    local yTileSize = loadedFile.tileheight
    local levelSizeX = xNumTiles * xTileSize
    local levelSizeY = yNumTiles * yTileSize

    -- Create a table of all the tilesets so that we can look up tiles in them after loading
    local tilesets = {}
    for i, tileset in ipairs(loadedFile.tilesets) do
        local localTileset = require(tileset.name)
        local set = Tileset:New(tileset.firstgid, localTileset)
        table.insert(tilesets, set)
    end
    table.sort(tilesets, sortByGid)

    -- Load all the tile surfaces and get their userdata so that we can use them when creating the atlas
    local loadedTilemapSurfaces = {}
    for _, tileset in ipairs(tilesets) do
        local filenames = tileset:GetAllFileNames()
        for _, value in ipairs(filenames) do
            local surfaceUserdata = Surface.NewFromFile(value)
            if surfaceUserdata then
                loadedTilemapSurfaces[value] = surfaceUserdata
            end
        end
    end

    -- Loop through data, and blit to it based on tilemaps
    for layerDepth, layer in ipairs(loadedFile.layers) do
        local layerAtlas = TileAtlas.New(levelSizeX, levelSizeY)
        -- Currently limiting layerdepth as we cannot handle object layers properly, only tile layers
        if layerDepth < 4 then
            local x, y = 0, 0
            for i, gid in ipairs(layer.data) do
                if gid ~= 0 then
                    local tileTileset = checkIfTileInTilesetList(gid, tilesets)
                    if tileTileset then
                        local tilePngName, srcX, srcY, width, height = tileTileset:GetTile(gid)
                        local dstX = x * xTileSize
                        local dstY = y * yTileSize
                        if tileTileset.imageTileset then
                            -- If this is an image, we need to raise it since they draw at bottom for some reason
                            dstY = dstY - height + yTileSize
                        end
                        local dstRect = Rectangle:New(dstX, dstY, width, height)
                        local srcRect = Rectangle:New(srcX, srcY, width, height)
                        local userdata = loadedTilemapSurfaces[tilePngName]
                        layerAtlas:BlitAtlasSurface(userdata, dstRect, srcRect)
                        -- BlitAtlasSurface(layer0Atlas, userdata, dstRect, srcRect)
                    end
                end
                if x < xNumTiles - 1 then
                    x = x + 1
                else
                    x = 0
                    y = y + 1
                end
            end
            layerDepth = layerDepth + 1
        end
        layerAtlas:CreateTextureFromSurface()
        table.insert(tilemap.tileSets, layerAtlas)
    end

    -- Cleanup the Surfaces we loaded from the tilemaps for ths level.
    for index, value in ipairs(loadedTilemapSurfaces) do
        Surface.Delete(value)

    end
    return tilemap
end

TileMap.__index = TileMap
return TileMap
