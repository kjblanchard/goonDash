#include <GoonDash/gnpch.h>
#include <GoonDash/misc/lua.h>
#include <GoonDash/scripting/LuaScripting.h>
#include <GoonDash/input/keyboard.h>
#include <SDL_ttf.h>
#include <SupergoonSound/include/sound.h>

#include <GoonPhysics/GoonPhysics.h>

// EMSCRIPTEN
#ifdef __EMSCRIPTEN__
#include <emscripten.h>
#endif

#define MAX_STARTUP_FRAMES 1000

static SDL_Event event;
static lua_State *L;
static bool shouldQuit = false;
static gpScene *scene;

static uint64_t lastFrameMilliseconds;
static float msBuildup;

// TODO this should be different, it is inside of SDLwindow.c
extern SDL_Renderer *g_pRenderer;
extern int g_refreshRate;

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
    // Initialize this frame
    Uint64 beginFrame = SDL_GetTicks64();
    Uint64 delta = beginFrame - lastFrameMilliseconds;
    msBuildup += delta;
    lastFrameMilliseconds = beginFrame;
    // Handle SDL inputs
    shouldQuit = sdlEventLoop();
    if (shouldQuit)
        return 0;
    // TODO make these static and pass into as ref to stop allocations
    // Initialize time this frame
    double deltaTimeSeconds = 1 / (double)g_refreshRate;
    double deltaTimeMs = 1000 / (double)g_refreshRate;
    if (msBuildup < deltaTimeMs)
        return true;
    SetLuaTableValue(L, "Lua", "DeltaTime", (void *)&deltaTimeSeconds, gLuaTableNumber);
    UpdateSound();


    // Run Update and update physics as many times as needed
    while (msBuildup >= deltaTimeMs)
    {
        gpSceneUpdate(scene, deltaTimeSeconds);
        CallEngineLuaFunction(L, "Update");
        msBuildup -= deltaTimeMs;
    }

    // Draw after we are caught up
    SDL_SetRenderDrawColor(g_pRenderer, 100, 100, 100, 255);
    SDL_RenderClear(g_pRenderer);
    CallEngineLuaFunction(L, "Draw");
    SDL_RenderPresent(g_pRenderer);
}

static void loop_wrap()
{
    loop_func();
}

int main()
{
    // Testing out Physics
    scene = gpInitScene();
    gpSceneSetGravity(scene, 300);
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
    if(TTF_Init() != 0)
    {
        LogError("Could not initialize SDL TTF\n,Error: %s", TTF_GetError());
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

    // Set last fram ms
    lastFrameMilliseconds = SDL_GetTicks64();

    // Main loop
#ifdef __EMSCRIPTEN__
    // emscripten_set_main_loop(loop_wrap, g_refreshRate, 1);
    emscripten_set_main_loop(loop_wrap, 60, 1);
#else
    while (!shouldQuit)
    {
        TIMED_BLOCK(int loopTime = loop_func();, "loopfunc")
    }
#endif

    // Exit
    SDL_Quit();
}