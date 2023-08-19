/**
 * @file SdlRect.h
 * @author your name (you@domain.com)
 * @brief
 * @version 0.1
 * @date 2023-07-30
 *
 * @copyright Copyright (c) 2023
 *
 */
#pragma once

typedef struct SDL_Rect SDL_Rect;
typedef struct lua_State lua_State;

SDL_Rect GetRectFromLuaTable(lua_State *L, int stackPos);