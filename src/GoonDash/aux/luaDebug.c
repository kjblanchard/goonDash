#include <GoonDash/gnpch.h>
#include <GoonDash/aux/luaDebug.h>

#ifdef GN_DEBUG_LUA
extern int luaopen_socket_core(lua_State *L);

int RegisterLuaSocketFunctions(lua_State *L)
{
    luaL_requiref(L, "socket.core", luaopen_socket_core, 1);
    return true;
}
#else
int RegisterLuaSocketFunctions(lua_State *L)
{
    return true;
}
#endif