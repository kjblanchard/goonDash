#include <GoonDash/gnpch.h>
#include <GoonDash/aux/lua.h>
#include <GoonDash/scripting/SdlWindow.h>

int main()
{
    InitializeDebugLogFile();
    InitializeLua();
    lua_State* L = GetGlobalLuaState();
    InitializeSdlWindowLuaFunctions(L);
    if (SDL_Init(SDL_INIT_EVERYTHING) != 0)
    {
        LogError("Could not Initialize SDL!\nError: %s", SDL_GetError());
        return 1;
    }
    LuaLoadFileIntoGlobalState("settings.lua");
    SDL_Quit();
}