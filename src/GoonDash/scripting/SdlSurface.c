#include <GoonDash/gnpch.h>
#include <GoonDash/scripting/SdlSurface.h>

#include <src/luasocket.h>

/**
 * @brief Loads from file and pushes It onto the lua scack if successful, otherwise nil
 *
 * @param L The Lua State pointer
 * @return int The amount of return objects on the stack.
 */
static int LoadSurfaceFromFile(lua_State *L)
{
    // Arg1: filepath
    const char *filePath = luaL_checkstring(L, 1);
    SDL_Surface *tileSurface = IMG_Load(filePath);
    LogWarn("Doing the thing");
    if (!tileSurface)
    {
        LogError("Could not load image %s, Error:\n%s", filePath, IMG_GetError());
        lua_pushnil(L);
        return 1;
    }
    lua_pushlightuserdata(L, tileSurface);
    return 1;
}

static int FreeSurface(lua_State *L)
{
    // Arg1: Sutface ptr lightuserdata
    if (!lua_islightuserdata(L, 1))
    {
        LogError("Bad argument passed into free surface, expected a userdata ptr to surface");
        lua_pushnil(L);
        return 0;
    }
    SDL_Surface *surface = (SDL_Surface *)lua_touserdata(L, 1);
    if (!surface)
    {
        LogError("Could not convert lightudata to surface");
        lua_pushnil(L);
        return 0;
    }
    SDL_FreeSurface(surface);
    return 0;
}

static int luaopen_LuaSurface(lua_State *L)
{
    luaL_newmetatable(L, "Lua.LuaSurface");
    luaL_Reg luaSurfaceLib[] = {
        {"NewFromFile", LoadSurfaceFromFile},
        {"Delete", FreeSurface},
        {NULL, NULL} // Sentinel value to indicate the end of the table
    };
    luaL_newlib(L, luaSurfaceLib);
    return 1;

}

int RegisterLuaSurfaceFunctions(lua_State* L)
{
    luaL_requiref(L, "LuaSurface", luaopen_LuaSurface, 0);
    luaL_requiref(L, "socket.core", luaopen_socket_core, 1);
}