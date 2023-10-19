#include <GoonDash/gnpch.h>
#include <GoonDash/misc/lua.h>
#include <GoonDash/scripting/LuaScripting.h>
#include <GoonDash/input/keyboard.h>
#include <SupergoonSound/include/sound.h>
#include <pthread.h>

// EMSCRIPTEN
#ifdef __EMSCRIPTEN__
#include <emscripten.h>
#endif

#define MAX_STARTUP_FRAMES 1000

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


static int loop_func()
{
    Uint64 beginFrame = SDL_GetTicks64();
    shouldQuit = sdlEventLoop();
    if (shouldQuit)
        return 0;
// Engine Updates
#ifdef GN_MULTITHREADED
    static pthread_t thread;
    if (pthread_create(&thread, NULL, MusicUpdateWrapper, NULL) != 0)
    {
        perror("pthread_create");
        return 0;
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
    return SDL_GetTicks64() - beginFrame;
#ifdef GN_MULTITHREADED
    // Wait for the thread to finish (optional)
    if (pthread_join(thread, NULL) != 0)
    {
        perror("pthread_join");
    }
#endif
    return SDL_GetTicks64() - beginFrame;
}

static void loop_wrap()
{
    loop_func();
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
    // Pump initial events out, to reduce large lag time at startup.
    sdlEventLoop();

    CallEngineLuaFunction(L, "Initialize");

    // Start
    CallEngineLuaFunction(L, "Start");

    // Main loop
#ifdef __EMSCRIPTEN__
    emscripten_set_main_loop(loop_wrap, 60, 1);
#else
    while (!shouldQuit)
    {

        TIMED_BLOCK(int loopTime = loop_func();, "loopfunc")
        int delayTime = 16 - loopTime;
        SDL_Delay(delayTime > 0 ? delayTime : 0);
    }
#endif

    // Exit
    SDL_Quit();
}