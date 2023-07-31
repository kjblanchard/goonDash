#include <GoonDash/gnpch.h>
#include <GoonDash/scripting/SdlSurface.h>
#include <GoonDash/scripting/SdlRect.h>

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
    if (!tileSurface)
    {
        LogError("Could not load image %s, Error:\n%s", filePath, IMG_GetError());
        lua_pushnil(L);
        return 1;
    }
    lua_pushlightuserdata(L, tileSurface);
    return 1;
}

static int LoadTextureAtlas(lua_State *L)
{
    // Arg1: Atlas Width
    // Arg2: Atlas Height
    int width = luaL_checkinteger(L, 1);
    int height = luaL_checkinteger(L, 2);
    SDL_Surface *atlasSurface = SDL_CreateRGBSurfaceWithFormat(0, width, height, 32, SDL_PIXELFORMAT_RGBA8888);
    if (!atlasSurface)
    {
        LogError("Could not create atlast surface, Error: %s", SDL_GetError());
        lua_pushnil(L);
        return 1;
    }
    lua_pushlightuserdata(L, atlasSurface);
    return 1;
}

static int BlitAtlasSurface(lua_State *L)
{
    // Arg1: DstAtlasSurface
    // Arg2: SrcTileSurface
    // Arg3: DstRect
    // Arg4: SrcRect
    if (!lua_islightuserdata(L, 1) || !lua_islightuserdata(L, 2))
    {
        LogError("Bad argument passed into blit surface, expected a userdata ptr to surface");
        lua_pushnil(L);
        return 0;
    }
    SDL_Surface *atlasSurface = (SDL_Surface *)lua_touserdata(L, 1);
    SDL_Surface *tileSurface = (SDL_Surface *)lua_touserdata(L, 2);
    SDL_Rect dstRect = GetRectFromLuaTable(L, 3);
    SDL_Rect srcRect = GetRectFromLuaTable(L, 4);
    SDL_BlitSurface(tileSurface, &srcRect, atlasSurface, &dstRect);
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
        {"NewAtlas", LoadTextureAtlas},
        {"BlitAtlas", BlitAtlasSurface},
        {"Delete", FreeSurface},
        {NULL, NULL} // Sentinel value to indicate the end of the table
    };
    luaL_newlib(L, luaSurfaceLib);
    return 1;
}

int RegisterLuaSurfaceFunctions(lua_State *L)
{
    luaL_requiref(L, "LuaSurface", luaopen_LuaSurface, 0);
}