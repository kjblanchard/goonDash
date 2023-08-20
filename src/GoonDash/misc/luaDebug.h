/**
 * @file luaDebug.h
 * @author your name (you@domain.com)
 * @brief
 * @version 0.1
 * @date 2023-07-30
 *
 * @copyright Copyright (c) 2023
 *
 */
#pragma once
/**
 * @brief Used when we need to debug lua, this should not be used on release, as we only use socket for connecting to the debugger.
 *
 * @param L The lua state
 * @return int if worky
 */
int RegisterLuaSocketFunctions(lua_State* L);