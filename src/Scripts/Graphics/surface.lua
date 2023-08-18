local surface = require("LuaSurface")
local LuaSurface = {}

---Create a new lua surface from file
---@param filename string The filename to load from
---@return userdata pointer to userdata in C
function LuaSurface.NewFromFile(filename)
    return surface.NewFromFile(filename)
end

function LuaSurface.CreateTexture(atlasSurface)
    return surface.CreateTexture(atlasSurface)
end


---Free the memory from C
---@param surface lightuserdata The loaded surface
function LuaSurface.Delete(surface)
    return surface.Delete(surface)
end

return LuaSurface
