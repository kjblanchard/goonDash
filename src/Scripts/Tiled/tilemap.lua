local TileMap = {}
local Tileset = require("Tiled.tileset")
local Rectangle = require("Core.rectangle")
local TileAtlas = require("Graphics.textureAtlas")
local Surface = require("Graphics.surface")
local debug = require("Core.debug")

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
local function getTilesetForTile(id, tilesetList)
    for i, tileset in ipairs(tilesetList) do
        if id >= tileset.firstGid and (tilesetList[i + 1] == nil or id < tilesetList[i + 1].firstGid) then
            return tileset
        end
    end
    print("Could not find a tileset containing this tile, something probably is wrong.")
    return nil
end

---Draws the background tile atlas, should be called before drawing all the gameobjects.
function TileMap:DrawBackground(camera)
    local rect = camera:GetRect()
    self.tileAtlases["background"]:DrawAtlas(rect)
end

function TileMap.New(filename)
    local tilemap = {}
    setmetatable(tilemap, TileMap)
    tilemap.__index = TileMap
    tilemap.tileAtlases = {}
    tilemap.DrawBackground = TileMap.DrawBackground
    local loadedFile = require(filename)
    local xNumTiles = loadedFile.width
    local yNumTiles = loadedFile.height
    local xTileSize = loadedFile.tilewidth
    local yTileSize = loadedFile.tileheight
    local levelSizeX = xNumTiles * xTileSize
    local levelSizeY = yNumTiles * yTileSize
    -- load the bgm from the tilemap, if it isn't set it will be null
    tilemap.bgm = loadedFile.properties.bgm
    -- set the size of the tilemap, for camera purposes
    tilemap.sizeX = levelSizeX
    tilemap.sizeY = levelSizeY
    -- Create a table of all the tilesets and sort them so that we can look up tiles in them after loading
    local tilesets = {}
    for _, tileset in ipairs(loadedFile.tilesets) do
        local localTileset = require(tileset.name)
        local set = Tileset:New(tileset.firstgid, localTileset)
        table.insert(tilesets, set)
    end
    table.sort(tilesets, sortByGid)
    -- Load all the tile surfaces and get their userdata so that we can use them when creating the atlas
    local loadedTilemapSurfaces = {}
    for _, tileset in ipairs(tilesets) do
        local filenames = tileset:GetAllFileNames()
        for _, tilesetFiles in ipairs(filenames) do
            local surfaceUserdata = Surface.NewFromFile(tilesetFiles)
            if surfaceUserdata then
                loadedTilemapSurfaces[tilesetFiles] = surfaceUserdata
            end
        end
    end
    -- Get tile map groups, and create a tile atlas for each.  Should be named "background" and "foreground"
    for _, tilemapLayer in ipairs(loadedFile.layers) do
        if tilemapLayer.type == "group" then
            local groupName = tilemapLayer.name
            local layerAtlas = TileAtlas.New(levelSizeX, levelSizeY)
            for _, groupLayer in ipairs(tilemapLayer.layers) do
                local dstX, dstY = 0, 0
                for i, gid in ipairs(groupLayer.data) do
                    if gid ~= 0 then --gid 0 is a blank tile in tiled
                        local tileTileset = getTilesetForTile(gid, tilesets)
                        if tileTileset then
                            local tilePngName, srcX, srcY, tileWidth, tileHeight = tileTileset:GetTile(gid)
                            local zeroBasedI = i - 1 --Need this so that we actually start drawing at 0 and not 1
                            dstX = math.floor(zeroBasedI % xNumTiles) * xTileSize
                            dstY = math.floor(zeroBasedI / xNumTiles) * yTileSize
                            if tileTileset.imageTileset then
                                -- If this is an imageTileset, we need to raise it since they draw at bottom for some reason in tiled
                                dstY = dstY - tileHeight + yTileSize
                            end
                            local dstRect = Rectangle.New(dstX, dstY, tileWidth, tileHeight)
                            local srcRect = Rectangle.New(srcX, srcY, tileWidth, tileHeight)
                            local srcRectSurfaceUserdata = loadedTilemapSurfaces[tilePngName]
                            local dst = dstRect:SdlRect()
                            local src = srcRect:SdlRect()
                            layerAtlas:BlitAtlasSurface(srcRectSurfaceUserdata, dst, src)
                        end
                    end
                end
            end
            layerAtlas:CreateTextureFromSurface()
            tilemap.tileAtlases[groupName] = layerAtlas
        elseif tilemapLayer.type == "objectgroup" and tilemapLayer.name == "entities" then
            debug.Debug("Entity layer found! adding to entity layer.")
            tilemap.entityLayer = tilemapLayer
        -- Handle solid objects
        elseif tilemapLayer.type == "objectgroup" and tilemapLayer.name == "solid" then
            debug.Debug("Solid layer found, adding to solid layer. ")
            tilemap.solidLayer = tilemapLayer
        end
    end
    -- Cleanup the Surfaces we loaded from the tilemaps for ths level.
    for _, surfaceUserdata in ipairs(loadedTilemapSurfaces) do
        Surface.Delete(surfaceUserdata)
    end
    if tilemap.entityLayer == nil then
        debug.Warn("No entity layer found in this tilemap, guess there is no gameobjects to load?")
    end
    if tilemap.solidLayer == nil then
        debug.Warn("No solid layer found in this tilemap, guess there is no solid objects to load?")
    end
    return tilemap
end

TileMap.__index = TileMap
return TileMap
