#include <GoonDash/gnpch.h>
#include <GoonDash/scripting/SdlSurface.h>
#include <GoonDash/scripting/SdlRect.h>
#include <GoonDash/scripting/SdlWindow.h>

/**
 * @brief Loads a surface from file and pushes It onto the lua stack if successful,
 * otherwise nil
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
/**
 * @brief Creates a texture atlas with the right height and width, only tested with png
 *
 * @param L The lua state
 * @return int Number of arguments pushed onto the stack.
 */
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

/**
 * @brief Used to draw onto a texture atlas.  Used for tile map operations mostly.
 *
 * @param L The lua state
 * @return int Number of items on the stack.
 */
static int BlitAtlasSurface(lua_State *L)
{
    // Arg1: DstAtlasSurface
    // Arg2: SrcTileSurface
    // Arg3: DstRect
    // Arg4: SrcRect
    if (!lua_islightuserdata(L, 1) || !lua_islightuserdata(L, 2))
    {
        LogError("Bad argument passed into blit surface, expected a userdata ptr to surface");
        // lua_pushnil(L);
        return 0;
    }
    SDL_Surface *atlasSurface = (SDL_Surface *)lua_touserdata(L, 1);
    SDL_Surface *tileSurface = (SDL_Surface *)lua_touserdata(L, 2);
    if(!atlasSurface || !tileSurface)
    {
        LogError("Somehow these are null. Atlas: %d, Tile: %d", atlasSurface, tileSurface);
        // lua_pushnil(L);
        return 0;
    }
    SDL_Rect dstRect = GetRectFromLuaTable(L, 3);
    SDL_Rect srcRect = GetRectFromLuaTable(L, 4);
    SDL_BlitSurface(tileSurface, &srcRect, atlasSurface, &dstRect);
    return 0;
}

/**
 * @brief Create a Texture From Surface object, and cleans up the surface.
 *
 * @param L
 * @return int
 */
static int CreateTextureFromSurface(lua_State *L)
{
    // Arg1: DstAtlasSurface
    if (!lua_islightuserdata(L, 1))
    {
        LogError("Bad argument passed into blit surface, expected a userdata ptr to surface");
        lua_pushnil(L);
        return 0;
    }
    SDL_Surface *atlasSurface = (SDL_Surface *)lua_touserdata(L, 1);
    SDL_Renderer *renderer = GetGlobalRenderer();
    // Convert the surface to a texture
    SDL_Texture *texture = SDL_CreateTextureFromSurface(renderer, atlasSurface);
    if (texture == NULL)
    {
        LogError("Could not create texture, Error: %s", SDL_GetError());
        lua_pushnil(L);
        return 0;
    }
    SDL_FreeSurface(atlasSurface); // We no longer need the surface after creating the texture
    lua_pushlightuserdata(L, texture);
    return 1;
}

static int DrawSurface(lua_State *L)
{
    // Arg1: DstAtlasSurface
    if (!lua_islightuserdata(L, 1))
    {
        LogError("Bad argument passed into blit surface, expected a userdata ptr to surface");
        lua_pushnil(L);
        return 0;
    }
    SDL_Texture *atlasTexture = (SDL_Texture *)lua_touserdata(L, 1);
    SDL_Renderer *renderer = GetGlobalRenderer();
    SDL_Rect dstRect = {0, 0, 512, 288};
    SDL_Rect srcRect = {0, 0, 512, 288};
    SDL_RenderCopy(renderer, atlasTexture, &srcRect, &dstRect);
    return 0;
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

static int luaopen_LuaTileAtlas(lua_State *L)
{
    luaL_newmetatable(L, "Lua.TileAtlas");
    luaL_Reg luaTileAtlasLib[] = {
        {"NewAtlas", LoadTextureAtlas},
        {"BlitAtlas", BlitAtlasSurface},
        {"CreateTexture", CreateTextureFromSurface},
        {"DrawAtlas", DrawSurface},
        {NULL, NULL} // Sentinel value to indicate the end of the table
    };
    luaL_newlib(L, luaTileAtlasLib);
    return 1;
}

static int luaopen_LuaSurface(lua_State *L)
{
    luaL_newmetatable(L, "Lua.LuaSurface");
    luaL_Reg luaSurfaceLib[] = {
        {"NewFromFile", LoadSurfaceFromFile},
        {"NewAtlas", LoadTextureAtlas},
        {"BlitAtlas", BlitAtlasSurface},
        {"DrawAtlas", DrawSurface},
        {"CreateTexture", CreateTextureFromSurface},
        {"Delete", FreeSurface},
        {NULL, NULL} // Sentinel value to indicate the end of the table
    };
    luaL_newlib(L, luaSurfaceLib);
    return 1;
}

int RegisterLuaSurfaceFunctions(lua_State *L)
{
    luaL_requiref(L, "LuaSurface", luaopen_LuaSurface, 0);
    luaL_requiref(L, "LuaTileAtlas", luaopen_LuaTileAtlas, 0);
}