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

typedef enum gLuaTableValueTypes {
    gLuaTableDefault = 0,
    gLuaTableNumber = 1,

} gLuaTableValueTypes;

int CallEngineLuaFunction(lua_State* L, const char* functionName);
int SetLuaTableValue(lua_State *L, const char *tableName, const char *tableKeyName, void *tableValue, gLuaTableValueTypes valueType);
void DumpLuaStack(lua_State *state);