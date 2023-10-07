#include <GoonDash/gnpch.h>
#include <GoonDash/misc/lua.h>
#include <GoonDash/misc/luaDebug.h>
#include <GoonDash/scripting/SdlWindow.h>
#include <GoonDash/scripting/SdlSurface.h>
#include <SupergoonSound/sound/sound.h>

// EMSCRIPTEN
#ifdef __EMSCRIPTEN__
#include <emscripten.h>
#endif

static SDL_Event event;
static SDL_Renderer *renderer;
static lua_State *L;
static bool shouldQuit = false;

void loop_func()
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
    if (shouldQuit)
        return;
    CallEngineLuaFunction(L, "Update");
    UpdateSound();
    SDL_SetRenderDrawColor(renderer, 100, 100, 100, 255);
    SDL_RenderClear(renderer);
    CallEngineLuaFunction(L, "Draw");
    SDL_RenderPresent(renderer);
}

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
    L = GetGlobalLuaState();
    RegisterLuaSocketFunctions(L);
    InitializeSdlWindowLuaFunctions(L);
    RegisterLuaSurfaceFunctions(L);

    if (!LuaLoadFileIntoGlobalState("main.lua"))
    {
        return false;
    }
    CallEngineLuaFunction(L, "Initialize");
    int result = InitializeSound();
    printf("Result is %d\n", result);
    Bgm *mainBgm = LoadBgm("audio/test.ogg", 20.397, 43.08);
    result = PlayBgm(mainBgm, 1.0);
    printf("Result is %d\n", result);

    // Set event loop
    renderer = GetGlobalRenderer();

    // Lua Start
    int startResult = CallEngineLuaFunction(L, "Start");
#ifdef __EMSCRIPTEN__
    emscripten_set_main_loop(loop_func, 60, 1);
#else
    while (!shouldQuit)
    {
        loop_func();
        SDL_Delay(16);
    }
#endif

    SDL_Quit();
}