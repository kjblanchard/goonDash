#include <GoonDash/scripting/SdlWindow.h>
#include <GoonDash/scripting/SdlSurface.h>
#include <GoonDash/scripting/Debug.h>
#include <GoonDash/scripting/Sound.h>

#include <GoonDash/misc/luaDebug.h>

int RegisterAllLuaFunctions(lua_State *L)
{
    RegisterLuaSocketFunctions(L);
    InitializeSdlWindowLuaFunctions(L);
    RegisterLuaSurfaceFunctions(L);
    RegisterDebugFunctions(L);
}