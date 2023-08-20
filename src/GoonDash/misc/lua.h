#pragma once
typedef struct lua_State lua_State;

int InitializeLua();
lua_State *GetGlobalLuaState();
/**
 * @brief Loads a lua file, and makes sure it is good
 *
 * @param L The global lua state to load it into
 * @param file The filename to load
 * @return int True if file was loaded successfully
 */
int LuaLoadFileIntoGlobalState(const char *file);

int CallEngineLuaFunction(lua_State* L, const char* functionName);
void DumpLuaStack(lua_State *state);