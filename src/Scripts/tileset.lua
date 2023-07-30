local TileSet = {
    data = nil,
    firstGid = nil,
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

---comment
---@param id any
---@return string | nil image filename, nil on error
---@return number | nil tile width, nil on error
---@return number | nil tile height, nil on error
function TileSet:GetTile(id)
    if self.imageTileset then
        -- This is a Image tileset
        for _, value in ipairs(self.data.tiles) do
            if value.id == id then
                return GetFullFilepath(value.image), value.width, value.height
            end
        end
    else
        -- This is a tile tileset
        -- convert image to proper name instead of the full path from tiled.
        local lastSection = string.match(self.data.image, ".+/(.+)")
        return GetFullFilepath(self.data.image), self.width, self.height
    end
    print('Could not find tile in this tileset: ' .. id)
    return nil, nil, nil
end

function TileSet:GetAllFileNames()
    local tilesets = {}
    print("Image tileset is " .. tostring(self.imageTileset))
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
