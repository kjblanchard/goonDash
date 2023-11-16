#include <GoonDash/gnpch.h>
#include <GoonDash/scripting/SdlWindow.h>

SDL_Window *g_pWindow = 0;
SDL_Renderer *g_pRenderer = 0;
int g_refreshRate = 60;

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
    if (g_pWindow == NULL)
    {
        LogError("Window could not be created, Error: %s", SDL_GetError());
        return 0;
    }
    g_pRenderer = SDL_CreateRenderer(g_pWindow, -1, SDL_RENDERER_ACCELERATED | SDL_RENDERER_PRESENTVSYNC);
    if (g_pRenderer == NULL)
    {
        LogError("Renderer could not be created, Error: %s", SDL_GetError());
    }
    LogDebug("Created window\nWidth: %d, Height: %d", width, height);
    SDL_DisplayMode mode;
    SDL_GetWindowDisplayMode(g_pWindow, &mode);
    g_refreshRate = mode.refresh_rate ? mode.refresh_rate : 60;
    // g_refreshRate = 60;
    // LogDebug("The refresh rate of the window is %d\n", mode.refresh_rate);
    LogWarn("The refresh rate of the window is %d\n", mode.refresh_rate);
    return 0;
}

SDL_Renderer *GetGlobalRenderer()
{
    return g_pRenderer;
}
SDL_Window *GetGlobalWindow()
{
    return g_pWindow;
}

int RegisterSdlWindowFunctions(lua_State *L)
{
    lua_pushcfunction(L, LuaCreateSdlWindow);
    lua_setglobal(L, "InitializeWindows");
}