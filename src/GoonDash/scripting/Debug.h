/**
 * @file Debug.h
 * @author Kevin blanchard (blanchardkevinj@gmail.com)
 * @brief
 * @version 0.1
 * @date 2023-10-08
 *
 * @copyright Copyright (c) 2023
 *
 */
#pragma once
typedef struct lua_State lua_State;
int RegisterDebugFunctions(lua_State *L);