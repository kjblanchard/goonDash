#include <GoonDash/gnpch.h>
#include <GoonDash/scripting/SdlRect.h>
#include <GoonDash/scripting/Draw.h>

// TODO these should be put somewhere
extern SDL_Window *g_pWindow;
extern SDL_Renderer *g_pRenderer;

/**
 * @brief Kind of inefficient, as it sets the render draw color to red and back every time currently
 *
 * @param L
 * @return int Doesn't return anything to lua
 */
static int DrawRect(lua_State *L)
{
    // Arg1: SdlRect to draw
    SDL_Rect dstRect = GetRectFromLuaTable(L, 1);
    uint8_t r, g, b, a;
    SDL_GetRenderDrawColor(g_pRenderer, &r, &g, &b, &a);
    SDL_SetRenderDrawColor(g_pRenderer, 255, 0, 0, 255);
    SDL_RenderDrawRect(g_pRenderer, &dstRect);
    SDL_SetRenderDrawColor(g_pRenderer, r, g, b, a);
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