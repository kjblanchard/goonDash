#pragma once
typedef struct lua_State lua_State;

int InitializeLua();
lua_State *GetGlobalLuaState();

/**
 * @brief For lua tables that are simple arrays.  Do something for each one, passing i and value into the func
 *
 * @param func
 * @return int
 */
int LuaForEachTable(lua_State *L, void (*func)(int, const char *, void *), void *modifyThing);
/**
 * @brief Loads a lua file, and makes sure it is good
 *
 * @param L The global lua state to load it into
 * @param file The filename to load
 * @return int True if file was loaded successfully
 */
int LuaLoadFileIntoGlobalState(const char *file);
void DumpLuaStack(lua_State *state);