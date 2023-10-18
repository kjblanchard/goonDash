#include <GoonDash/gnpch.h>
#include <GoonDash/misc/lua.h>
#include <SupergoonSound/sound/sound.h>
#include <GoonDash/scripting/LuaScripting.h>
#include <GoonDash/input/keyboard.h>

#include <pthread.h>
pthread_t thread;

// EMSCRIPTEN
#ifdef __EMSCRIPTEN__
#include <emscripten.h>
#endif

static SDL_Event event;
static lua_State *L;
static bool shouldQuit = false;

// TODO this should be different, it is inside of SDLwindow.c
extern SDL_Renderer *g_pRenderer;

void *MusicUpdateWrapper(void *arg)
{
    UpdateSound();
    return NULL;
}

/**
 * @brief Handles all SDL events every frame.
 *
 * @return true If we should quit or not
 * @return false If we should quit or not
 */
static bool sdlEventLoop()
{
    // Event loop, Handle SDL events.
    while (SDL_PollEvent(&event))
    {
        switch (event.type)
        {
        case SDL_QUIT:
            return true;
            break;
        case SDL_KEYDOWN:
        case SDL_KEYUP:
            HandleKeyboardEvent(&event, L);
            break;
        default:
            break;
        }
    }
    return false;
}

static void loop_func()
{
    shouldQuit = sdlEventLoop();
    if (shouldQuit)
        return;
// Engine Updates
#ifdef GN_MULTITHREADED
    if (pthread_create(&thread, NULL, MusicUpdateWrapper, NULL) != 0)
    {
        perror("pthread_create");
        return;
    }
#else
    UpdateSound();
#endif
    // Lua Update
    CallEngineLuaFunction(L, "Update");
    // Rendering
    SDL_SetRenderDrawColor(g_pRenderer, 100, 100, 100, 255);
    SDL_RenderClear(g_pRenderer);
    CallEngineLuaFunction(L, "Draw");
    SDL_RenderPresent(g_pRenderer);
    // Wait for the thread to finish (optional)
    if (pthread_join(thread, NULL) != 0)
    {
        perror("pthread_join");
        return;
    }
}

int main()
{
    // Initialize Engine
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
    int result = InitializeSound();
    if (!result)
    {
        LogError("Could not initialize Sound for some reason!");
    }

    RegisterAllLuaFunctions(L);

    // Load Main.lua
    if (!LuaLoadFileIntoGlobalState("main.lua"))
    {
        return false;
    }

    CallEngineLuaFunction(L, "Initialize");

    // Start
    CallEngineLuaFunction(L, "Start");

    // Main loop
#ifdef __EMSCRIPTEN__
    emscripten_set_main_loop(loop_func, 60, 1);
#else
    while (!shouldQuit)
    {
        loop_func();
        SDL_Delay(16);
    }
#endif

    // Exit
    SDL_Quit();
}