#include <GoonDash/gnpch.h>
#include <GoonDash/scripting/SdlRect.h>

SDL_Rect GetRectFromLuaTable(lua_State *L, int stackPos)
{
    if (!lua_istable(L, stackPos))
    {
        SDL_Rect rect = {.x = 0, .y = 0, .w = 0, .h = 0};
        return rect;
    }
    int x = luaL_checkinteger(L, lua_getfield(L, stackPos, "x"));
    int y = luaL_checkinteger(L, lua_getfield(L, stackPos, "y"));
    int width = luaL_checkinteger(L, lua_getfield(L, stackPos, "width"));
    int height = luaL_checkinteger(L, lua_getfield(L, stackPos, "height"));
    SDL_Rect rect = {.x = x, .y = y, .w = width, .h = height};
    return rect;
}