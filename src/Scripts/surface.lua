local surface = require("LuaSurface")
local LuaSurface = {}
--- A way to handle SDL surfaces in lua from C
-- LuaSurface = require("LuaSurface")
---Initialize a SDL window
---@param name string The name of the window
---@param width number The size of the window
---@param height number The height of the window
function InitializeWindow(name, width, height) end

---Create a new lua surface from file
---@param filename string The filename to load from
---@return userdata pointer to userdata in C
function LuaSurface.NewFromFile(filename)
    return surface.NewFromFile(filename)
end

---Free the memory from C
---@param surface lightuserdata The loaded surface
function LuaSurface.Delete(surface)
    return surface.Delete(surface)
end

return LuaSurface
