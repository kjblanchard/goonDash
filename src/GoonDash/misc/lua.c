#include <GoonDash/gnpch.h>
#include <GoonDash/misc/lua.h>

// This could possibly need to be : instead of ; on Windows, we will find out when building there.
#define SCRIPT_PATH "./Scripts/?.lua;./assets/tiled/?.lua;/Users/kevin/.luarocks/share/lua/5.4/?.lua;/Users/kevin/build/macosx/share/lua/5.4/?.lua;/Users/kevin/build/macosx/share/lua/5.4/socket/?.lua"
// #define BUFFER_SIZE 1000

static lua_State *g_luaState;

/**
 * @brief Sets the package.path In lua so that it knows how to properly look when files use require.
 *
 * @param state
 * @param path
 * @return int
 */
static int SetLuaPath(lua_State *state, const char *path)
{
  int value = lua_getglobal(state, "package");
  if (value == LUA_TNIL)
    LogWarn("Borked");
  lua_getfield(state, -1, "path");                    // get field "path" from table at top of stack (-1)
  const char *current_path = lua_tostring(state, -1); // grab path string from top of stack
  size_t full_str_len = strlen(current_path) + strlen(path) + 1;
  // Change windows
  // char full_str[BUFFER_SIZE];
  char *full_str = calloc(1, full_str_len * sizeof(char));
  snprintf(full_str, full_str_len, "%s;%s", current_path, path);
  lua_pop(state, 1);               // get rid of the string on the stack we just pushed on line 5
  lua_pushstring(state, full_str); // push the new one
  free(full_str);
  lua_setfield(state, -2, "path"); // set the field "path" in table at -2 with value at top of stack
  lua_settop(state, 0);
  return 0;
}

int InitializeLua()
{
  g_luaState = luaL_newstate();
  luaL_openlibs(g_luaState);
  SetLuaPath(g_luaState, SCRIPT_PATH);
  return 1;
}

lua_State *GetGlobalLuaState()
{
  return g_luaState;
}
int LuaLoadFileIntoGlobalState(const char *file)
{
  const char *prefix = "./Scripts/";
  size_t bufferSize = strlen(file) + strlen(prefix) + 1;
  // change windows
  // char buf[bufferSize];
  char *buf = calloc(1, bufferSize * sizeof(char));
  snprintf(buf, bufferSize, "%s%s", prefix, file);
  luaL_loadfile(g_luaState, buf);
  free(buf);
  int result = lua_pcall(g_luaState, 0, 0, 0);
  if (result != LUA_OK)
  {
    const char *error = lua_tostring(g_luaState, -1);
    LogError("Could not load file %s, error result: %d, error: %s", buf, result, error);
    lua_pop(g_luaState, 1);
    return false;
  }
  return true;
}
void DumpLuaStack(lua_State *state)
{
  int top = lua_gettop(state);
  for (int i = 1; i <= top; i++)
  {
    LogWarn("%d\t%s\t", i, luaL_typename(state, i));
    switch (lua_type(state, i))
    {
    case LUA_TNUMBER:
      LogWarn("%g", lua_tonumber(state, i));
      break;
    case LUA_TSTRING:
      LogWarn("%s", lua_tostring(state, i));
      break;
    case LUA_TBOOLEAN:
      LogWarn("%s", (lua_toboolean(state, i) ? "true" : "false"));
      break;
    case LUA_TNIL:
      LogWarn("%s", "nil");
      break;
    default:
      LogWarn("%p", lua_topointer(state, i));
      break;
    }
  }
}

int CallEngineLuaFunction(lua_State *L, const char *functionName)
{
  lua_getglobal(L, "Lua");
  lua_getfield(L, -1, functionName);
  int result = lua_pcall(g_luaState, 0, 0, 0);
  if (result != LUA_OK)
  {
    const char *error = lua_tostring(g_luaState, -1);
    LogError("Failed script, %s, error result: %d, error: %s", functionName, result, error);
    lua_pop(g_luaState, 1);
    return false;
  }
  return true;
  lua_settop(L, 0);
}