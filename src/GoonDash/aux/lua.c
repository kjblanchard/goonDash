#include <GoonDash/gnpch.h>
#include <GoonDash/aux/lua.h>

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
    size_t full_str_len = strlen(current_path) + strlen(path) + 2;
    char full_str[full_str_len];
    sprintf(full_str, "%s;%s", current_path, path);
    lua_pop(state, 1);               // get rid of the string on the stack we just pushed on line 5
    lua_pushstring(state, full_str); // push the new one
    lua_setfield(state, -2, "path"); // set the field "path" in table at -2 with value at top of stack
    lua_settop(state, 0);
    return 0;
}

int InitializeLua()
{
  g_luaState = luaL_newstate();
  luaL_openlibs(g_luaState);
  SetLuaPath(g_luaState, "./Scripts/?.lua");
  return 1;
}

lua_State *GetGlobalLuaState()
{
  return g_luaState;
}

int LuaForEachTable(lua_State *L, void (*func)(int, const char *, void *), void *modifyThing)
{
  lua_pushnil(L);
  while (lua_next(L, -2))
  {
    // stack now contains: -1 => value; -2 => key; -3 => table
    // copy the key so that lua_tostring does not modify the original
    lua_pushvalue(L, -2);
    // stack now contains: -1 => key; -2 => value; -3 => key; -4 => table
    int key = lua_tointeger(L, -1) - 1;
    const char *value = lua_tostring(L, -2);
    func(key, value, modifyThing);
    // pop value + copy of key, leaving original key
    lua_pop(L, 2);
    // stack now contains: -1 => key; -2 => table
  }
  return 0;
}

int LuaLoadFileIntoGlobalState(const char *file)
{
  // static const int bufferSize = 100;
  // char buf[bufferSize];
  // snprintf(buf, bufferSize, "./scripts/%s", file);
  // snprintf(buf, bufferSize, "./scripts/%s", file);
  // luaL_loadfile(g_luaState, buf);
  luaL_loadfile(g_luaState, file);
  int result = lua_pcall(g_luaState, 0, 0, 0);
  if (result != LUA_OK)
  {
    const char *error = lua_tostring(g_luaState, -1);
    // LogError("Could not load file %s, error result: %d, error: %s", buf, result, error);
    LogError("Could not load file %s, error result: %d, error: %s", file, result, error);
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