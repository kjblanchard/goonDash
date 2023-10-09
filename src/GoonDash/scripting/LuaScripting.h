/**
 * @file LuaScripting.c
 * @author Kevin Blanchard (kevin@supergoon.com)
 * @brief
 * @version 0.1
 * @date 2023-10-08
 *
 * @copyright Copyright (c) 2023
 *
 */

#pragma once
typedef struct lua_State lua_State;
/**
 * @brief Registers all the C functions exposed to lua.
 *
 * @param L The lua state to register all of these into.
 */
void RegisterAllLuaFunctions(lua_State *L);