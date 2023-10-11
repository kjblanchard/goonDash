#include <GoonDash/gnpch.h>
#include <GoonDash/scripting/SdlRect.h>
#include <GoonDash/misc/lua.h>

SDL_Rect GetRectFromLuaTable(lua_State *L, int stackPos)
{
    // This seems pretty inefficient every time we pass a rect from lua... maybe use fulluserdata,
    // but then rects become expensive in lua.
    if (!lua_istable(L, stackPos))
    {
        SDL_Rect rect = {.x = 0, .y = 0, .w = 0, .h = 0};
        return rect;
    }
    lua_getfield(L, stackPos, "x");
    int x = luaL_checkinteger(L, -1);
    lua_getfield(L, stackPos, "y");
    int y = luaL_checkinteger(L, -1);
    lua_getfield(L, stackPos, "w");
    int width = luaL_checkinteger(L, -1);
    lua_getfield(L, stackPos, "h");
    int height = luaL_checkinteger(L, -1);
    SDL_Rect rect = {.x = x, .y = y, .w = width, .h = height};
    lua_pop(L, 4);
    return rect;
}