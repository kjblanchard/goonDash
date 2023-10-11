local Rectangle = {
    x = 0,
    y = 0,
    width = 0,
    height = 0
}

---Creates a new Rectangle
---@param x number X location
---@param y number Y location
---@param width number Width
---@param height number Height
function Rectangle.New(x, y, width, height)
    local rect = setmetatable({}, Rectangle)
    rect.x = x or 0
    rect.y = y or 0
    rect.width = width or 0
    rect.height = height or 0
    return rect
end

---Gets this rectagle and passes a table with SDL Rect stuff only
---@return table Packed into a SDL_Rect, could use lightuserdata or something, but don't want dynamic alloc in C.
function Rectangle:SdlRect()
    local thing = { x = self.x, y = self.y, w =  self.width, h = self.height }
    return thing
end

Rectangle.__index = Rectangle
Rectangle.__tostring = function(rect)
    return ("X: " .. rect.x .. " Y: " .. rect.y .. " W: " .. rect.width .. " H: " .. rect.width)
end
return Rectangle
