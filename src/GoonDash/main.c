#include <GoonDash/gnpch.h>
#include <GoonDash/aux/lua.h>
#include <GoonDash/aux/luaDebug.h>
#include <GoonDash/scripting/SdlWindow.h>
#include <GoonDash/scripting/SdlSurface.h>

int main()
{
    InitializeDebugLogFile();
    InitializeLua();
    if (SDL_Init(SDL_INIT_EVERYTHING) != 0)
    {
        LogError("Could not Initialize SDL!\nError: %s", SDL_GetError());
        return 1;
    }
    lua_State *L = GetGlobalLuaState();
    RegisterLuaSocketFunctions(L);
    InitializeSdlWindowLuaFunctions(L);
    RegisterLuaSurfaceFunctions(L);

    LuaLoadFileIntoGlobalState("settings.lua");
    static bool shouldQuit = false;
    static SDL_Event event;
    SDL_Renderer *renderer = GetGlobalRenderer();
    SDL_SetRenderDrawColor(renderer, 0, 0, 0, 255);
    while (!shouldQuit)
    {
        // For now, just process events and check for quit and draw to the screen.
        while (SDL_PollEvent(&event))
        {
            switch (event.type)
            {
            case SDL_QUIT:
                shouldQuit = true; // Quit the loop if the window close button is clicked
                break;
            case SDL_KEYDOWN:
                if (event.key.keysym.sym == SDLK_q)
                {
                    shouldQuit = true; // Quit the loop if 'q' key is pressed
                }
                break;
            default:
                break;
            }
        }
        SDL_RenderClear(renderer);
        SDL_SetRenderDrawColor(renderer, 0, 0, 0, 255);
        // Should draw the atlas in lua
        // // // // //TODO this is for testing
        lua_getglobal(L, "DrawAtlas");
        // Call the function (0 arguments, 0 return values)
        int status = lua_pcall(L, 0, 0, 0);
        if (status != LUA_OK)
        {
            // Handle any errors that occurred during the function call
            printf("Error calling DrawAtlas(): %s\n", lua_tostring(L, -1));
            lua_pop(L, 1); // Pop the error message from the stack
        }
        // // // // //
        SDL_RenderPresent(renderer);
        SDL_Delay(16);
    }
    SDL_Quit();
}