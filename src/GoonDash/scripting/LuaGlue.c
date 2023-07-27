#include <GoonDash/gnpch.h>
#include <GoonDash/scripting/LuaGlue.h>
#include <GoonDash/aux/lua.h>


void InitializeBotLuaL()
{
    lua_State* L = GetGlobalLuaState();
    lua_getglobal(L, "InitializeBot");
    //-1 Func
    if(lua_pcall(L, 0, 0, 0) != LUA_OK)
    {
        LogError("Error running function: %s", lua_tostring(L, -1));
    }
}

void UpdateBotLuaL()
{
    lua_State* L = GetGlobalLuaState();
    lua_getglobal(L, "UpdateBot");
    //-1 Func
    if(lua_pcall(L, 0, 0, 0) != LUA_OK)
    {
        LogError("Error running function: %s", lua_tostring(L, -1));
    }
}