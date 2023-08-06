local Renderer = {}
---Initialize a SDL window
---@param name string The name of the window
---@param width number The size of the window
---@param height number The height of the window
function Renderer.InitializeWindow(name, width, height)
    InitializeWindows(name, width, height)

end


Renderer.__index = Renderer
return Renderer