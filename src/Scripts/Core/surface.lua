local surface = require("LuaSurface")
local LuaSurface = {}

---Create a new lua surface from file
---@param filename string The filename to load from
---@return userdata pointer to userdata in C
function LuaSurface.NewFromFile(filename)
    return surface.NewFromFile(filename)
end

---Create a blank texture atlas, so that we can use this to draw the static tiles on
---@param width integer the width of the atlas, should be integer
---@param height integer the height of the atlas
---@return lightuserdata The loaded surface ptr
function LuaSurface.LoadTextureAtlas(width, height)
    return surface.NewAtlas(width, height)
end

function LuaSurface.CreateTexture(atlasSurface)
    return surface.CreateTexture(atlasSurface)
end

function LuaSurface.DrawAtlas(atlasTexture)
    return surface.DrawAtlas(atlasTexture)
end

---Draw onto the texture atlas, used when preparing the tilemap surface.
---@param atlasSurface lightuserdata The loaded atlas surface ptr
---@param tileSurface lightuserdata The loaded tile surface ptr
---@param destRect table the rectangle to use for the dest
---@param srcRect table the rectangle to use from the tile
---@return unknown
function BlitAtlasSurface(atlasSurface, tileSurface, destRect, srcRect)
    return surface.BlitAtlas(atlasSurface, tileSurface, destRect, srcRect)
end

---Free the memory from C
---@param surface lightuserdata The loaded surface
function LuaSurface.Delete(surface)
    return surface.Delete(surface)
end

return LuaSurface
