local TileSet = {
    data = nil,
    firstGid = nil,
    lastGid = nil,
    imageTileset = false
}

local function GetFullFilepath(tiledPath)
    local ImageFilepath = './assets/img/'
    local lastSection = string.match(tiledPath, ".+/(.+)")
    return ImageFilepath .. lastSection
end

function TileSet:New(firstGid, data)
    local tileset = {}
    setmetatable(tileset, self)
    tileset.data = data
    tileset.firstGid = firstGid
    tileset.imageTileset = tileset.data.image == nil and true or false
    return tileset
end

---@param id any
---@return string | nil image filename, nil on error
---@return number | nil tile src x
---@return number | nil tile src y
---@return number | nil tile width, nil on error
---@return number | nil tile height, nil on error
function TileSet:GetTile(id)
    if self.imageTileset then
        -- This is a Image tileset
        for _, value in ipairs(self.data.tiles) do
            if value.id + self.firstGid == id then
                return GetFullFilepath(value.image), 0, 0, value.width, value.height
            end
        end
    else
        -- This is a tile tileset
        -- convert image to proper name instead of the full path from tiled.
        local lastSection = string.match(self.data.image, ".+/(.+)")
        local indexInTileset = id - 1 --This needs to be offset by 1 due to gid0 being empty
        local srcX, srcY = 0,0
        srcX = math.floor(indexInTileset % self.data.columns) * self.data.tilewidth
        srcY = math.floor(indexInTileset / self.data.columns) * self.data.tileheight
        return GetFullFilepath(self.data.image), srcX, srcY, self.data.tilewidth, self.data.tileheight
    end
    print('Could not find tile in this tileset: ' .. id)
    return nil, nil, nil
end

function TileSet:GetAllFileNames()
    local tilesets = {}
    if self.imageTileset then
        for _, tile in ipairs(self.data.tiles) do
            table.insert(tilesets, GetFullFilepath(tile.image))
        end
    else
        table.insert(tilesets, GetFullFilepath(self.data.image))
    end
    return tilesets
end

TileSet.__index = TileSet

return TileSet
