local textureAtlas = require("LuaTileAtlas")
local LuaTextureAtlas = {
    _atlasUserdataSurface = nil,
    _atlasUserdataTexture = nil
}

function LuaTextureAtlas:CreateTextureFromSurface()
    if self._atlasUserdataSurface and not self._atlasUserdataTexture then
        self._atlasUserdataTexture = textureAtlas.CreateTexture(self._atlasUserdataSurface)
        self._atlasUserdataSurface = nil
    end

end

function LuaTextureAtlas:DrawAtlas()
    return textureAtlas.DrawAtlas(self._atlasUserdataTexture)
end

---Draw onto the texture atlas, used when preparing the tilemap surface.
---@param tileSurface lightuserdata The loaded tile surface ptr
---@param destRect table the rectangle to use for the dest
---@param srcRect table the rectangle to use from the tile
---@return unknown
function LuaTextureAtlas:BlitAtlasSurface(tileSurface, destRect, srcRect)
    return textureAtlas.BlitAtlas(self._atlasUserdataSurface, tileSurface, destRect, srcRect)
end

---Create a blank texture atlas, so that we can use this to draw the static tiles on
---@param width number the width of the atlas, should be integer
---@param height number the height of the atlas
function LuaTextureAtlas.New(width, height)
    local atlas = {}
    setmetatable(atlas, LuaTextureAtlas)
    atlas.__index = LuaTextureAtlas
    atlas._atlasUserdataSurface = textureAtlas.NewAtlas(width, height)
    atlas.BlitAtlasSurface = LuaTextureAtlas.BlitAtlasSurface
    atlas.DrawAtlas = LuaTextureAtlas.DrawAtlas
    atlas.CreateTextureFromSurface = LuaTextureAtlas.CreateTextureFromSurface
    return atlas
end
LuaTextureAtlas.__index = LuaTextureAtlas
return LuaTextureAtlas
