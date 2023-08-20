#include <GoonDash/gnpch.h>
#include <GoonDash/misc/lua.h>
#include <GoonDash/misc/luaDebug.h>
#include <GoonDash/scripting/SdlWindow.h>
#include <GoonDash/scripting/SdlSurface.h>

int main()
{
    InitializeDebugLogFile();
    InitializeLua();
    if (SDL_Init(SDL_INIT_VIDEO | SDL_INIT_GAMECONTROLLER) != 0)
    {
        LogError("Could not Initialize SDL!\nError: %s", SDL_GetError());
        return 1;
    }
    if (IMG_Init(IMG_INIT_PNG) == 0)
    {
        LogError("Could not initialize SDL_IMAGE\nError: %s", IMG_GetError());
    }
    lua_State *L = GetGlobalLuaState();
    RegisterLuaSocketFunctions(L);
    InitializeSdlWindowLuaFunctions(L);
    RegisterLuaSurfaceFunctions(L);

    // Start lua
    LuaLoadFileIntoGlobalState("main.lua");
    CallEngineLuaFunction(L, "Initialize");

    // Set event loop
    static bool shouldQuit = false;
    static SDL_Event event;
    SDL_Renderer *renderer = GetGlobalRenderer();

    // Lua Start
    CallEngineLuaFunction(L, "Start");

    // Update loop
    while (!shouldQuit)
    {
        // Event loop
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
        // Lua Update
        CallEngineLuaFunction(L, "Update");

        // Lua Draw
        SDL_SetRenderDrawColor(renderer, 0, 0, 0, 255);
        SDL_RenderClear(renderer);
        CallEngineLuaFunction(L, "Draw");
        SDL_RenderPresent(renderer);

        // Delay currently
        SDL_Delay(16);
    }
    SDL_Quit();
}