#include <GoonDash/gnpch.h>
#include <GoonDash/scripting/SdlRect.h>
#include <GoonDash/scripting/Draw.h>

// TODO these should be put somewhere
extern SDL_Window *g_pWindow;
extern SDL_Renderer *g_pRenderer;

static int DrawRect(lua_State *L)
{
    // Arg1: SdlRect
    SDL_Rect dstRect = GetRectFromLuaTable(L, 1);
    SDL_RenderDrawRect(g_pRenderer, &dstRect);
    return 0;

}

static int luaopen_GoonDraw(lua_State *L)
{
    luaL_newmetatable(L, "Lua.Draw");
    luaL_Reg luaDrawLib[] = {
        {"DrawRect", DrawRect},
        {NULL, NULL} // Sentinel value to indicate the end of the table
    };
    luaL_newlib(L, luaDrawLib);
    return true;
}

int RegisterDrawFunctions(lua_State *L)
{
    luaL_requiref(L, "GoonDraw", luaopen_GoonDraw, 0);
    return true;
}