/**
 * @file Draw.h
 * @author Kevin Blanchard (kevin@supergoon.com)
 * @brief Drawing functions exposed to lua
 * @version 0.1
 * @date 2023-10-21
 *
 * @copyright Copyright (c) 2023
 *
 */
#pragma once
typedef struct lua_State lua_State;
int RegisterDrawFunctions(lua_State *L);