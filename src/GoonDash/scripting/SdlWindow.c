#include <GoonDash/gnpch.h>
#include <GoonDash/scripting/SdlWindow.h>

SDL_Window *g_pWindow = 0;
SDL_Renderer *g_pRenderer = 0;

/**
 * @brief
 * Lua params: string name, int window width, int window height
 *
 * @param L
 * @return int
 */
static int LuaCreateSdlWindow(lua_State *L)
{
    const char *windowName = luaL_checkstring(L, 1);
    int width = luaL_checkinteger(L, 2);
    int height = luaL_checkinteger(L, 3);
    g_pWindow = SDL_CreateWindow(windowName,
                                 SDL_WINDOWPOS_CENTERED, SDL_WINDOWPOS_CENTERED,
                                 width, height,
                                 SDL_WINDOW_SHOWN);
    // if the window creation succeeded create our renderer
    if (g_pWindow != 0)
    {
        g_pRenderer = SDL_CreateRenderer(g_pWindow, -1, 0);
    }
    SDL_SetRenderDrawColor(g_pRenderer, 0, 0, 0, 255);
    SDL_RenderClear(g_pRenderer);
    SDL_RenderPresent(g_pRenderer);
    SDL_Delay(5000);
    return 0;
}
int InitializeSdlWindowLuaFunctions(lua_State *L)
{
    lua_pushcfunction(L, LuaCreateSdlWindow);
    lua_setglobal(L, "InitializeWindow");
}