#include <GoonDash/gnpch.h>
#include <GoonDash/scripting/Debug.h>

/**
 * @brief Handles debug messages from lua, and routes them accordingly.
 *
 * @param L The lua state
 * @return int Always returns true.
 */
static int Message(lua_State *L)
{
    // Arg1: String
    // Arg2: Type
    const char *string = luaL_checkstring(L, 1);
    int level = luaL_checkinteger(L, 2);
    switch (level)
    {
    case 1:
        LogDebug(string);
        break;
    case 2:
        LogInfo(string);
        break;
    case 3:
        LogWarn(string);
        break;
    case 4:
        LogError(string);
        break;
    default:
        LogWarn("Somehow your Log message from lua didn't hit any log types, message %s", string);
        break;
    }
    return true;
}

static int SetDebugLogLevel(lua_State *L)
{
    // Arg1 int
    int logLevel = luaL_checkinteger(L, 1);
    if (logLevel > Log_LDefault && logLevel < Log_LMax)
        SetLogLevel(logLevel);
    return 0;
}

static int luaopen_GoonDebug(lua_State *L)
{
    luaL_newmetatable(L, "Lua.GoonDebug");
    luaL_Reg luaDebugLib[] = {
        {"Message", Message},
        {"SetLogLevel", SetDebugLogLevel},
        {NULL, NULL} // Sentinel value to indicate the end of the table
    };
    luaL_newlib(L, luaDebugLib);
    return true;
}

int RegisterDebugFunctions(lua_State *L)
{
    luaL_requiref(L, "GoonDebug", luaopen_GoonDebug, 0);
    return true;
}