#include <GoonDash/scripting/SdlWindow.h>
#include <GoonDash/scripting/SdlSurface.h>
#include <GoonDash/scripting/Debug.h>
#include <GoonDash/scripting/Sound.h>
#include <GoonDash/misc/luaDebug.h>

void RegisterAllLuaFunctions(lua_State *L)
{
    RegisterLuaSocketFunctions(L);
    RegisterSdlWindowFunctions(L);
    RegisterSurfaceFunctions(L);
    RegisterDebugFunctions(L);
    RegisterSoundFunctions(L);
}