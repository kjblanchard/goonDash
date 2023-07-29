#include <GoonDash/gnpch.h>
#include <GoonDash/aux/lua.h>
#include <GoonDash/scripting/SdlWindow.h>
#include <GoonDash/scripting/SdlSurface.h>

int main()
{
    InitializeDebugLogFile();
    InitializeLua();
    lua_State* L = GetGlobalLuaState();
    InitializeSdlWindowLuaFunctions(L);
    luaL_requiref(L, "LuaSurface", luaopen_LuaSurface, 1);
    if (SDL_Init(SDL_INIT_EVERYTHING) != 0)
    {
        LogError("Could not Initialize SDL!\nError: %s", SDL_GetError());
        return 1;
    }
    LuaLoadFileIntoGlobalState("settings.lua");
    SDL_Delay(2000);
    SDL_Quit();
}