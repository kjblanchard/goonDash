#include <GoonDash/gnpch.h>
#include <GoonDash/aux/lua.h>
#include <GoonDash/aux/luaDebug.h>
#include <GoonDash/scripting/SdlWindow.h>
#include <GoonDash/scripting/SdlSurface.h>

int main()
{
    InitializeDebugLogFile();
    InitializeLua();
    lua_State* L = GetGlobalLuaState();
    RegisterLuaSocketFunctions(L);
    InitializeSdlWindowLuaFunctions(L);
    RegisterLuaSurfaceFunctions(L);

    if (SDL_Init(SDL_INIT_EVERYTHING) != 0)
    {
        LogError("Could not Initialize SDL!\nError: %s", SDL_GetError());
        return 1;
    }
    LuaLoadFileIntoGlobalState("settings.lua");
    SDL_Delay(2000);
    SDL_Quit();
}